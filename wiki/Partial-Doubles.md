# <div class="warning">This page has not been updated for GUT 9.0.0 or Godot 4.  There could be incorrect information here.</div>
A partial double is basically the inverse of a doubled object.  It creates an object that acts exactly the same way as its source but has hooks that allows us to stub or spy on any method.

The `partial_double` method will create a partial double "class" which you can instance.  You can partially double scripts, packed scenes, and inner classes.  It works the same way as `double` works, so read up on that and then apply all that new knowledge to `partial_double`.

Under the covers, whether you call `double` or `partial_double`, GUT makes the same thing.  If you call `partial_double` though, it will setup the object's methods to be stubbed `to_call_super` instead of not being stubbed at all.

After you have your partial double, you can stub methods to return values instead of doing what they normally do.  You can also spy on any of the methods.

__NOTE__ As of 7.0.0, in an attempt to help tests create less orphans, all Doubles and Partial Doubles are freed when a test finishes.  This means you do not have to free them manually and you should not use them in `before_all`.

## Script Example

Given
```gdscript
# res://script.gd
extends Node2D

var _value = 10

func set_value(val):
  _value = val

func get_value():
  return _value
```

Then
```gdscript
func test_things():
  var partial = partial_double('res://script.gd').new()
  stub(partial, 'set_value').to_do_nothing()
  partial.set_value(20) # stubbed so implementation bypassed.

  # since set_value was stubbed, and get_value was not, and since
  # this is a partial stub, then the original functionality of
  # get_value will be executed and _value is returned.
  assert_eq(partial.get_value(), 10)
  # unstubbed partial methods can be spied on.
  assert_called(partial, 'get_value')
  # stubbed methods can be spied on as well
  assert_called(partial, 'set_value', [20])
```

## Packed Scene Example
Given you have a scene `res://scene.tscn` that has the following script:
```gdscript
# res://script.gd
extends Node2D

var _value = 10

func set_value(val):
  _value = val

func get_value():
  return _value
```
Then
```gdscript
var partial = partial_double('res://scene.tscn').instance()
# or
var Scene = load('res://scene.tscn')
var partial = partial_double(Scene).instance()
```

## Inner Class Example
```gdscript
# res://script.gd
extends Node2D

class InnerClass:
  var _value = 10

  func set_value(val):
    _value = val

  func get_value():
    return _value
```
Then
```gdscript
var partial = partial_double('res://script.gd', 'InnerClass').new()
# or
var Script = load('res://script.gd')
var partial = partial_double(Script, 'InnerClass').new()
```

## Overriding Doubling Strategy
Partial doubles also support overriding the set Experimental Doubling Strategy.  Pass in the strategy as an optional last parameter in any of the cases above.  It will override the strategy used when creating just this one partial double Class.
