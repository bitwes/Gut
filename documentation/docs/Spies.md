# Spies
When a `double` is instanced, Gut will record calls to methods that are defined in the script or scripts it inherits from.  You can then make assertions to check if a method was called, not called, passed certain values, or how many times it was called.

You should read the page on doubling before using this, as there are some gotchas with doubling.

__You can only spy on methods that have been included in the Double.  Built-in functions (such as `set_position`) are not doubled by default, so you cannot spy on them unless you have set the [Double Strategy](Double-Strategy).__

## Spy Related Methods
The following methods can be used to "spy" on doubled objects.  They are available in any script that extends `GutTest`.
* `assert_called`
* `assert_not_called`
* `assert_call_count`
* `get_call_parameters`
* `get_call_count`

### assert_called
`assert_called(inst, method_name, parameters=null)`<br>
This assertion is is one of the ways Gut implements Spies.  It requires that you pass it an instance of a "doubled" object.  An instance created with `double` will record when a method it has is called.  You can then make assertions based on this.

This assert will check the object to see if a call to the specified method (optionally with parameters) was called over the course of the test.  If it finds a match this test will `pass`, if not it will `fail`.

The `parameters` parameter is an array of values that you expect to have been passed to `method_name`.  If you do not specify any parameters then any call to `method_name` will match and the assert will `pass`.  If you specify parameters then all the parameter values must match.  You must specify all parameters the method takes, even if they have defaults.


``` gdscript
# Given the following class located at 'res://test/doubler_test_objects/double_extends_node2d.gd'
# --------------------
	extends Node2D
	var _value = 0

	func get_value():
	    return _value
	func set_value(val):
	    _value = val
	func has_one_param(one):
	    pass
	func has_two_params_one_default(one, two=null):
	    pass
	func get_position():
	    return .get_position()
# --------------------

# This is how assert_called behaves
func test_assert_called():
	var DOUBLE_ME_PATH = 'res://test/doubler_test_objects/double_extends_node2d.gd'

	var doubled = double(DOUBLE_ME_PATH).new()
	doubled.set_value(4)
	doubled.set_value(5)
	doubled.has_two_params_one_default('a')
	doubled.has_two_params_one_default('a', 'b')

	gut.p('-- passing --')
	assert_called(doubled, 'set_value')
	assert_called(doubled, 'set_value', [5])
	# note the passing of `null` here.  Default parameters must be supplied.
	assert_called(doubled, 'has_two_params_one_default', ['a', null])
	assert_called(doubled, 'has_two_params_one_default', ['a', 'b'])

	gut.p('-- failing --')
	assert_called(doubled, 'get_value')
	assert_called(doubled, 'set_value', ['nope'])
	# This fails b/c Gut isn't smart enough to fill in default values for you...
	# ast least not yet.
	assert_called(doubled, 'has_two_params_one_default', ['a'])
	# This fails with a specific message indicating that you have to pass an
	# instance of a doubled class.
	assert_called(GDScript.new(), 'some_method')
```


### assert_not_called
`assert_not_called(inst, method_name, parameters=null)`<br>
This is the inverse of `assert_called` and works the same way except, you know, inversely.  Matches are found based on parameters in the same fashion.  If a matching call is found then this assert will `fail`, if not it will `pass`.


### assert_call_count
`assert_call_count(inst, method_name, expected_count, parameters=null)`<br>
This assertion is is one of the ways Gut implements Spies.  It requires that you pass it an instance of a "doubled" object.  An instance created with `double` will record when a method it has is called.  You can then make assertions based on this.

Asserts that a method on a doubled instance has been called a number of times.  If you do not specify any parameters then all calls to the method will be counted.  If you specify parameters, then only those calls that were passed matching values will be counted.

The `parameters` parameter is an array of values that you expect to have been passed to `method_name`.  If you do not specify any parameters then any call to `method_name` will match and the assert will `pass`.  If you specify parameters then all the parameter values must match.  You must specify all parameters the method takes, even if they have defaults.  Gut is not able (yet?) to fill in default values.


``` gdscript
# Given the following class located at 'res://test/doubler_test_objects/double_extends_node2d.gd'
# --------------------
	extends Node2D
	var _value = 0

	func get_value():
	    return _value
	func set_value(val):
	    _value = val
	func has_one_param(one):
	    pass
	func has_two_params_one_default(one, two=null):
	    pass
	func get_position():
	    return .get_position()
# --------------------

# This is how assert_call_count behaves
func test_assert_call_count():
	var DOUBLE_ME_PATH = 'res://test/doubler_test_objects/double_extends_node2d.gd'

	var doubled = double(DOUBLE_ME_PATH).new()
	doubled.set_value(4)
	doubled.set_value(5)
	doubled.has_two_params_one_default('a')
	doubled.has_two_params_one_default('a', 'b')
	doubled.set_position(Vector2(100, 100))

	gut.p('-- passing --')
	assert_call_count(doubled, 'set_value', 2)
	assert_call_count(doubled, 'set_value', 1, [4])
	# note the passing of `null` here.  Default parameters must be supplied.
	assert_call_count(doubled, 'has_two_params_one_default', 1, ['a', null])
	assert_call_count(doubled, 'get_value', 0)

	gut.p('-- failing --')
	assert_call_count(doubled, 'set_value', 5)
	assert_call_count(doubled, 'set_value', 2, [4])
	assert_call_count(doubled, 'get_value', 1)
	# This fails with a specific message indicating that you have to pass an
	# instance of a doubled class even though technically the method was called.
	assert_call_count(GDScript.new(), 'some_method', 0)
	# This fails b/c double_extends_node2d does not have it's own implementation
	# of set_position.  The function is supplied by the parent class and these
	# methods are not yet being recorded.
	assert_call_count(doubled, 'set_position', 1)

```

### get_call_parameters
`get_call_parameters(object, method_name, index=-1)`<br>

This will return the parameters that were passed to the call of method as an array.  By default it returns the most recent call to the method.  You can specify the optional index to get any of the calls that were made to the method.  `null` is returned if a call to the specified method was not found.


### get_call_count
`get_call_count(object, method_name, parameters=null)`<br>

Returns the call count for a method with optional paramter matching.  See `assert_call_count` for info about parameter matching.