# 4.7 Issues

## Doubling abstract classes issue
Abstract methods do not include a return type in the metadata, only implemented abstract methods have a return type.

Given
```gdscript
@abstract
class AbstractClass:
	@abstract
	func abstract_method() -> Variant
```
The metadata is
```
{
  "args": [],
  "default_args": [],
  "flags": 129,
  "id": 0,
  "name": "abstract_method",
  "return": {
    "class_name": "",
    "hint": 0,
    "hint_string": "",
    "name": "",
    "type": 0,
    "usage": 6
  }
}
```
But if you implement it
```gdscript
class ExtendsAbstract:
	extends AbstractClass

	func abstract_method() -> int:
		return 10
```
The metadata is
```
{
  "args": [],
  "default_args": [],
  "flags": 1,
  "id": 0,
  "name": "abstract_method",
  "return": {
    "class_name": "",
    "hint": 0,
    "hint_string": "",
    "name": "",
    "type": 2,
    "usage": 0
  }
}
```
### Solution
Maybe a stub for return type.  Otherwise you have to create a local class that implements the abastract method and use that for doubling.


## Doubling and Void Return Type Issue
Given
```
class Example:
	func explicit_void() -> void:
		pass

	func inferred_void():
		pass
```
There is no way to tell the difference between the return types of `explicit_void` and `inferred_void` from the metadata.  Both look like they have a void return type.  Since there is no way to know, you cannot stub `inferred_void` to return a value.

The real issue is that you cannot have a `return` clause in `explicit_void`, but since I can't tell the difference, I cannot include a `return` clause in `inferred_void`, even though it is valid GDScript.

```
--- explicit_void() ---
{
  "args": [],
  "default_args": [],
  "flags": 1,
  "id": 0,
  "name": "explicit_void",
  "return": {
    "class_name": "",
    "hint": 0,
    "hint_string": "",
    "name": "",
    "type": 0,
    "usage": 6
  }
}

--- inferred_void() ---
{
  "args": [],
  "default_args": [],
  "flags": 1,
  "id": 0,
  "name": "inferred_void",
  "return": {
    "class_name": "",
    "hint": 0,
    "hint_string": "",
    "name": "",
    "type": 0,
    "usage": 6
  }
}
```
### Solution
Maybe a stub for return type.  The user can also just add a `return` to the method and that will change the metadata.
```
# This now becomes an inferred Variant return type
func inferred_void():
	return
```
This is probably the right answer, but GUT can't give specific messages to tell the user what should be done.



## Doubles and return type enforcement issue
Godot has become more strict with function return types.  In previous versions you could return `null` in overriden methods.  This is no longer possible.  The following worked in 4.6, but results in a parser error in 4.7.
```gdscript
class Example:
	func int_return() -> int:
		return 10

class ExtendsExample:
	extends Example

	func int_return():
		return null
```

### Solution
I think this will require default return values for all return types.  I'm not sure if they need to be changeable by the user.  Should `int` be 0?  Probably, but maybe it should be max or min int value.  Should `Vector2` be (0, 0)?  Maybe.  If you need a specific value, you should stub instead, which is what you'd have to do if it returned `null`.  It's just that before, you would get an error about `null`, and now you'll get a valid value which could be misleading.



# Implementation
* Based on return type in metadata, include `return` in doubles.
* Add Stub `return_type` which would work at the class level, not instance.
	* Useful with abstract classes
	* Useful if you have a method where super does not implicitly return a value but you expect it to in an extended class.
* Improve stub `to_return` to stub `return_type` if done to the class and not an instance and method looks to have a `void` return.
* `stub_private_methods_to_call_super`?  I'm questioning the usability of a double if you have to stub all the methods that have return values to return a valid value instead of null.
* Might need to have default values for all datatypes.
	* It might be useful to make this editable.
	* Change values per script (you could just wrap making your doubles with a method)
	* Changing values per test does not make sense, since it's essentially the same as stubbing (though it does allow you to psuedo stub all methods with the same return type to a specific value with a single line.)
	* `GutDoubleReturnDefaults`
		* `set_value(TYPE_X/class_ref, value)`
		* `init_parameters(class_ref, ...args)`
		* `get_value(TYPE_X/class_ref)`
		* null defaults
			* `Object`
			* `Variant`
			* `RefCounted` ?
			* `Node` ?
	* could `GutDoubleReturnDefaults` be `GutDoubleDefaults` and be used when creating new instances of things elsewhere?
