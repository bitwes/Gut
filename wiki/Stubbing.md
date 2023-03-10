# !! Not Updated for GUT 9.0.0 Yet !!
##### Table of Contents
* The Fine Print
* Syntax
* Stubbing based off of parameter values
* Stubbing Packed Scenes
* Stubbing Method Paramter Defaults
* Stubbing Method Paramter Count
---


The `stub` function allows you to set return values for methods for a doubled script or instance.  You can stub any doubled class to return values.  Stubs can be layered to address general and specific situations.

You can also use `stub` to set default parameter values and change the parameter count for a method.

# The fine print
Because of how doubling works, you can only stub methods that are implemented in your script or any scripts that inherits from.  You can stub most built-in methods if you use the experimental FULL doubling strategy.  Check the bottom of the doubling page for more information.

# Syntax
```
var inst = double('res://script.gd').new()
stub(inst, 'some_method').to_return("I'm stubbed!")
```
* `stub(obj, method)`  This stubs the value for a method.  You must chain in a call to one of the "to" methods such as `to_return(...)`.  The first parameter can be a path to a script or a loaded script or an instance of a doubled object.  When you pass in a path or class, then all doubles of that script will have the stub by default.  You can override this by calling `stub` on an instance of a doubled object.

After calling `stub` you must chain one of the following "to" methods after.
* `.to_return(value)` Stubs the method to return the passed value.
* `.to_call_super()`  This will cause the method to punch through to the implementation in the super class so it will retain its original functionality.
* `.to_do_nothing()`  This is the same as calling `.to_return(null)` but it is more readable and shows the intent of what you are doing.

You can optionally chain in the `when_passed` clause as well.
* `.when_passed(p1, p2, p3....p10)`  This can optionally be called on the result of `stub` in order to stub a value when specific parameters are passed to the method.  It supports up to 10 parameters.  Let me know if you need more.  For example:
```
stub('res://script.gd', 'method').to_return(-5).when_passed('minus', 'five')
```

You can also alter a method's signature with
* `.param_defaults([])`
* `.param_count(x)`
See below for more information about setting parameter default values and changing parameter counts.

## Example

Here is a simple example

Given the `double_this` class:
``` gdscript
# res://scripts/double_this.gd
extends Node2D

var foo = -1
var bar = 10

func return_seven():
  return 7

func return_hello(param=1):
  return 'hello'

class InnerClass:
  var another_foo = 100
```
Then, from inside your test script you can do the following to alter the `return_seven` method to return `500`
```gdscript
func test_something():
  var inst = double('res://scripts/double_this.gd').new()
  stub('res://scripts/double_this.gd', 'return_seven').to_return(500)
  assert_eq(inst.return_seven(), 500)
```
The `stub` method is pretty smart about what you pass it.  You can pass it a path, an Object or an instance.  If you pass an instance, it __must__ be an instance of a double.

When passed an Object or a path, it will stub the value for __all__ instances that do not have explicitly defined stubs.  When you pass it an instance of a doubled class, then the stubbed return will only be set for that instance.
```gdscript
var DoubleThis = load('res://scripts/double_this.gd')
var Doubled = double('res://scripts/double_this.gd')

# these two are equivalent
stub('res://scripts/double_this.gd', 'return_seven').to_return(500)
stub(DoubleThis, 'return_seven').to_return(500)

# This will stub the value for the passed in instance ONLY.
# Any other instances will return 500 from the lines above.
var doubled_inst = Doubled.new()
stub(doubled_inst, 'return_seven').to_return('words')
```

# Stubbing based off of parameter values
You can stub a method to return a specific value based on what was passed in.
```gdscript
const DOUBLE_THIS_PATH = 'res://scripts/double_this.gd'
var Doubled = double(DOUBLE_THI_PATH)
stub(DOUBLE_THIS_PATH, 'return_hello').to_return('world').when_passed(7)
```
The ordering of `when_passed` and `to_return` does not matter.

# Stubbing Packed Scenes
When stubbing doubled scenes, use the path to the scene, __not__ the path to the scene's script.  If you double and stub the script used by the scene, the `instance` you make from `double_scene` will not return values stubbed for the script.  It will only return values stubbed for the scene.

In order for a scene to be doubled, the scene's script must be able to be instantiated with `new` with zero parameters passed.

## Example
Given the script `res://the_script.gd`:
```gdscript
func return_hello():
  return 'hello'
```
And given a scene with the path `res://double_this_scene.tscn` which has its script set to `res://the_script.gd`.

The following asserts will pass
``` gdscript
func test_illustrate_stubbing_scenes():
  const SCENE_PATH = 'res://double_this_scene.tscn'
  const SCRIPT_PATH = 'res://the_script.gd'

  var scene = double_scene(SCENE_PATH).instance()
  var script = double(SCRIPT_PATH).new()

  stub(SCENE_PATH, 'return_hello').to_return('world')
  stub(SCRIPT_PATH, 'return_hello').to_return('goodbye')

  assert_eq(scene.return_hello(), 'world')
  assert_eq(script.return_hello(), 'goodbye')
```

# Stubbing Method Paramter Defaults
Godot only provides information about default values for built in methods so Gut doesn't know what any default values are for methods you have created.  Since it can't know, Gut defaults all parameters to `null`.  This can cause issues in specific cases (probably all invovling calling super).  You can use `.param_defaults` to specify default values to be used.

Here's an example where things go wrong
```
# res://foo.gd
var _sum  = 0
func increment(inc_by=1):
  _sum += inc_by

func go_up_one():
  increment()

func get_sum():
  return _sum
```

The following test will cause a `Invalid operands 'int' and 'Nil'` error.  This is because increment's `inc_by` parameter is defaulted to `null` in the double.
```
var Foo = load('res://foo.gd')
test_go_up_one_increments_sum_by_1():
  var dbl_foo = double(Foo).new()
  stub(dbl_foo, 'go_up_one').to_call_super()

  dbl_foo.go_up_one()
  assert_called(dbl_foo, 'increment', [1])
```

The fix is to add a `param_defaults` stub
```
stub(dbl_foo, 'increment').param_defaults([1])
```

# Stubbing Method Paramter Count
<u>__Changing the number of parameters must be done before `double` is called__</u>

Some built-in methods  have `vararg` parameters.  This makes the paramter list dynamic.  Godot does not provide this information.  This can cause errors due to a signature mismatch.  Your code might be calling a method using 10 parameter values but Gut only sees two.

Let's take `Node.rpc_id` for example.  It has two normal parameters and then a vararg of strings as the last paramter.
```
Variant rpc_id(peer_id: int, method: String, ...) vararg
```
If this method gets called in a parital double with more than 2 parameters Godot will will throw _Invalid call to function 'rpc_id' in base 'Control ()'. Expected 2 arguments._

You can use `.param_count(x)` to tell Gut to give the method any number of extra parameters.  You cannot make the method have less parameters.  You must do this before you call `double`.
``` gdscript
func test_issue_246_rpc_id_varargs():
  # must happen before double is called
  stub(Node, 'rpc_id').to_do_nothing().param_count(5)

  var inst = double(Node).new()
  inst.rpc_id(1, 'foo', '3', '4', '5')
  assert_called(inst, 'rpc_id', [1, 'foo', '3', '4', '5'])
```

You can also use `.param_defaults` to specify extra parameters if you supply more defaults than the method has parameters.

``` gdscript
func test_issue_246_rpc_id_varargs_with_defaults():
  # must happen before double is called
  stub(Node, 'rpc_id').to_do_nothing().param_defaults([null, null, 'a', 'b', 'c'])

  var inst = double(Node).new()
  inst.rpc_id(1, 'foo', 'z')
  assert_called(inst, 'rpc_id', [1, 'foo', 'z', 'b', 'c'])
```
You cannot make a method have less parameters, only more.









