#### <a name="assert_property"> assert_property(obj, name_property, default_value, set_to_value)
This method does a couple of common tests for properties.
It checks if:
* the named setter and getter functions exist
* the given default value is set_to_value
* the value is set correctly to the given `set_to_value`
* the named setter and getter functions are called when the property is accessed directly

It fails if at least one of the mentioned sub-checks fails.

The parameter `obj` can be any `Object`. Depending on what you put in the function will try retrieve the underlying class or to instantiate from `obj`. It is tested for classes extending `Script` or `PackedScene` in case you want to put in a class / scene. It is tested for objects extending the `Node` class. The method may fail if you try to put in something else.

Under the cover it runs `assert_accessors` and `assert_setget_called`. Look into [assert_accessors](#assert_accessors) or [assert_setget_called](#assert_setget_called) to get further information on how they work.

In the following script you can see some examples how to use this assert function. The class under test is a "Health" component. It has a `max_hap` field with no setter or getter assigned. It also has a `current_hp` property with assigned setter and getter functions.

```python
gut.p('-- class under test --')
class Health:
  extends Node


  export(int) var max_hp = 0
  export(int) var current_hp = 0 setget set_current_hp, get_current_hp


  func set_max_hp(value: int) -> void:
  	if value < 0:
  		value = 0
  	max_hp = value


  func get_max_hp() -> int:
  	return max_hp


  func set_current_hp(value: int) -> void:
  	current_hp = clamp(value, 0, max_hp)


  func get_current_hp() -> int:
  	return current_hp


gut.p('-- passing --')
assert_property(Health, 'current_hp', 0, 0) # PASS
var health = Health.new()
health.max_hp = 10
assert_property(health, 'current_hp', 0, 5) # PASS

gut.p('-- failing --')
assert_property(Health, 'max_hp', 0, 5) # FAIL => no setget keyword
assert_property(Health, 'current_hp', 0, 5) # FAIL => method will clamp current_hp to max_hp which is 0 by default
var directory = Directory.new()
assert_property(directory, 'current_dir', '', 'new_dir') # FAIL => directory is not a Resource nor a Node

```
