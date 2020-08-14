#### <a name="assert_setget_called"> assert_setget_called(type, name_property, name_setter="", name_getter="")
This method checks if the named setter and getter functions are called when the given property is accessed.

In GDScript this is realized by using the `setget` keyword. The keyword requires you to specify a setter or getter function, you can also specify both:

```python
class SomeClass:
  var property_both = null setget set_property_both, get_property_both
  var property_setter = null setget set_property_setter
  var property_getter = null setget , get_property_getter
  var normal_class_attribute = null
  var another_property = null setget some_completely_different_name, another_different_name
```

With this assert you can test for scenarios equivalent to `property_both`, `property_setter` and `property_getter`. As shown in the example GDScript allows any names for the setter and getter functions. With this assert you can test for this scenario as well. With this assert you cannot test for normal class attributes.

The parameter `type` has to be a `Resource`. Therefore you can put in a `Script` or a `PackedScene` but no instances of your class / scene under test.

The parameters `name_setter` and `name_getter` are optional.

In the following script you can see some examples how to use this assert function. The class under test is a "Health" component. It has a `max_hap` field with no setter or getter assigned. It also has a `current_hp` property with assigned setter and getter functions. For slightly more convenient ways to test properties with setget keyword also look into [assert_setget](#assert_setget) or [assert_property](#assert_property). They wrap around this assert function and set some common defaults to safe you some time.

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
assert_setget_called(Health, 'current_hp', 'set_current_hp', 'get_current_hp') # PASS
assert_setget_called(Health, 'current_hp', 'set_current_hp') # PASS
assert_setget_called(Health, 'current_hp', '', 'get_current_hp') # PASS


gut.p('-- failing --')
assert_setget_called(Health, 'max_hp', 'set_max_hp') # FAIL
assert_setget_called(Health, 'max_hp') # FAIL => out of scope
assert_setget_called(Health, 'current_hp') # FAIL => setter or getter name must be specified
assert_setget_called(Health, 'current_hp', 'set_curent_hp', 'get_current_hp') # FAIL => typo...
var health = Health.new()
assert_setget_called(health, 'current_hp', 'set_current_hp') # FAIL => type has to be a Resource
assert_setget_called(Health, max_hp, null, null) # FAIL => methods do not exist
assert_setget_called(Health, max_hp, 1, 1)  # FAIL => methods do not exist
assert_setget_called(5, 'current_hp', 'set_current_hp')  # FAIL => type has to be a Resource
assert_setget_called(double(Health), 'current_hp', 'set_current_hp') # FAIL => type has to be a Resource that can be doubled
```

Please note the last example. So far an already doubled type cannot be doubled again. Since the class under test will be doubled within the assert procession it is important to only feed in types that can be doubled. For more information about doubling its restrictions see the wiki page about [Doubles](https://github.com/bitwes/Gut/wiki/Doubles).
