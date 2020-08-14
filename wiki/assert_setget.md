#### <a name="assert_setget"> assert_is_property(obj, name_property, has_setter=false, has_getter=false)
This method checks if the named setter and getter functions are called when the given property is accessed.

In GDScript this is realized by using the `setget` keyword. The keyword requires you to specify a setter or getter function, you can also specify both:

```python
class SomeClass:
  var property_both = null setget set_property_both, get_property_both
  var property_setter = null setget set_property_setter
  var property_getter = null setget , get_property_getter
```

The parameter `obj` can be any `Object`. Depending on what you put in the function will try retrieve the underlying class or to instantiate from `obj`. It is tested for classes extending `Script` or `PackedScene` in case you want to put in a class / scene. It is tested for objects extending the `Node` class. The method may fail if you try to put in something else.

The parameters `name_setter` and `name_getter` are optional.

Under the cover it runs `assert_setget_called`. Look into [assert_setget_called](#assert_setget_called) to get further information on how it works.

In the following script you can see some examples how to use this assert function. The class under test is a "Health bar" component. It has a `health` field with a setter but no getter assigned.

```python
gut.p('-- class under test --')
class HealthBar:
  extends Control

const Health = preload("res://some_path/health.gd")
var health: Health = null setget set_health

onready var progress_bar = $ProgressBar
onready var label = $Label


func set_health(node: Health) -> void:
	health = node


func _on_Health_updated() -> void:
	if health != null:
		label.text = "%s / %s" %[health.current_hp, health.max_hp]
		progress_bar.max_value = health.max_hp
		progress_bar.value = health.current_hp


gut.p('-- passing --')
assert_setget(HealthBar, 'health', true) # PASS
var health_bar = load("res://some_path/HealthBar.tscn").instance()
assert_setget(health_bar, 'health', true) # PASS

gut.p('-- failing --')
assert_setget(HealthBar, 'label') # FAIL => setter or getter has to be specified
assert_setget(HealthBar, 'label', true) # FAIL => setter does not exist
```
