##### Table of Contents
* [Syntax](#syntax)
* [Stubbing based off of parameter values](#stubbing-based-off-of-parameter-values)
* [Stubbing Packed Scenes](#stubbing-packed-scenes)
* [Stubbing Method Parameter Defaults](#stubbing-method-parameter-defaults)
* [Stubbing Method Parameter Count](#stubbing-method-parameter-count)
* [Stubbing Accessors](#stubbing-accessors)
---


The `stub` function allows you to set return values for methods for a doubled script or instance.  You can stub any doubled class to return values.  Stubs can be layered to address general and specific situations.

You can also use `stub` to set default parameter values and change the parameter count for a method.


# Syntax
```gdscript
var MyScript = load('res://my_script.gd')
var inst = double(MyScript).new()
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

func returns_seven():
  return 7

func return_hello(param=1):
  return 'hello'

class InnerClass:
  var another_foo = 100
```
Then, from inside your test script you can do the following to alter the `returns_seven` method to return `500`
```gdscript
var DoubleThis = load('res://scripts/double_this.gd')

func test_something():
  var inst = double(DoubleThis).new()
  stub(inst, 'returns_seven').to_return(500)
  assert_eq(inst.returns_seven(), 500)
```
The `stub` method is pretty smart about what you pass it.  You can pass it a path, an Object or an instance.  If you pass an instance, it __must__ be an instance of a double.

When passed an Object or a path, it will stub the value for __all__ instances that do not have explicitly defined stubs.  When you pass it an instance of a doubled class, then the stubbed return will only be set for that instance.
```gdscript
var DoubleThis = load('res://scripts/double_this.gd')
var Doubled = double(DoubleThis)

# These two are equivalent, and stub returns_seven for any doubles of
# DoubleThis to return 500.
stub('res://scripts/double_this.gd', 'returns_seven').to_return(500)
stub(DoubleThis, 'returns_seven').to_return(500)
var inst = Doubled.new()
assert_eq(inst.returns_seven(), 500)

# This will stub returns_seven on the passed in instance ONLY.
# Any other instances will return 500 from the lines above.
var stub_again = Doubled.new()
stub(stub_again, 'returns_seven').to_return('words')
assert_eq(stub_again.returns_seven(), 'words')
```

# Stubbing based off of parameter values
You can stub a method to return a specific value based on what was passed in.
```gdscript
var DoubleThis = load('res://scripts/double_this.gd')
var Doubled = double(DoubleThis)
stub(DoubleThis, 'return_hello').to_return('world').when_passed('hello')

var inst = Doubled.new()
assert_eq(inst.return_hello(), 'hello')
assert_eq(inst.return_hello('hello'), 'world')
```
The ordering of `when_passed` and `to_return` does not matter.

# Stubbing Packed Scenes
When stubbing doubled scenes, use the path to the scene, __not__ the path to the scene's script.  If you double and stub the script used by the scene, the `instance` you make from `double_scene` will not return values stubbed for the script.  It will only return values stubbed for the scene.

In order for a scene to be doubled, the scene's script must be able to be instantiated with `new` with zero parameters passed.

## Example
Given the script `res://the_script.gd`:
``` gdscript
func return_hello():
  return 'hello'
```
And given a scene with the path `res://double_this_scene.tscn` which has its script set to `res://the_script.gd`.

``` gdscript
var DoubleThisScene = load('res://double_this_scene.tscn')

func test_illustrate_stubbing_scenes():
  var doubled_scene = double(DoubleThisScene).instantiate()
  stub(doubled_scene, 'return_hello').to_return('world')

  assert_eq(doubled_scene.return_hello(), 'world')
```

# Stubbing Method Parameter Defaults
Godot only provides information about default values for built in methods so Gut doesn't know what any default values are for methods you have created.  Since it can't know, Gut defaults all parameters to `null`.  This can cause issues in specific cases (probably all involving calling super).  You can use `.param_defaults` to specify default values to be used.

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

# Stubbing Method Parameter Count
<u>__Changing the number of parameters must be done before `double` is called__</u>

Some built-in methods  have `vararg` parameters.  This makes the parameter list dynamic.  Godot does not provide this information.  This can cause errors due to a signature mismatch.  Your code might be calling a method using 10 parameter values but Gut only sees two.

Let's take `Node.rpc_id` for example.  It has two normal parameters and then a vararg of strings as the last parameter.
```
Variant rpc_id(peer_id: int, method: String, ...) vararg
```
If this method gets called in a partial double with more than 2 parameters Godot will will throw _Invalid call to function 'rpc_id' in base 'Control ()'. Expected 2 arguments._

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


# Stubbing Accessors
It is not possible to stub the accessors for properties if you do not use a secondary method for the accessors.  This means that doubles retain the functionality of the accessors, and it cannot be changed.
``` gdscript
# The get and set for my_property cannot be stubbed.  Doubles retain the
# functionality of the get and set methods.
var my_property = 'foo' :
  get: return my_property
  set(val): my_property = val
```

If you use secondary methods, you can stub the behavior, but all doubles will not have any functionality for the accessors by default.
```gdscript
# You can stub _get_my_property and _set_my_property.  Doubles of this do not
# retain the functionality of the accessors.  _get_my_property and
# _set_my_property must be stubbed to_call_super to actually return or set
# the value of my_property.
var my_property = 'foo' :
  get: _get_my_property, set: _set_my_property

func _get_my_property():
  return my_property

func _set_my_property(val):
  my_property = val
```






