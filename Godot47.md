# 4.7 Issues

## The super weird issue
```gdscript
	func test_can_call_all_methods_in_all_return_types():
		gut.get_doubler().print_source = true
		var Dbl = double(TestResourceAllReturnTypes)
		var dbl = Dbl.new()
		# print('get_script = ', dbl.get_script())
		# print("******************** ", dbl.return_int())
		# GutUtils.pretty_print(Dbl.get_script_method_list())
		GutUtils.pretty_print(dbl.__gutdbl_values)
		for entry in Dbl.get_script_method_list():
			var method_name = entry.name
			var result = dbl.call(method_name)
			print("called ", method_name, " got ", result)

		GutUtils.pretty_print(dbl.__gutdbl_values)
		for method_name in dbl.__gutdbl_values.doubled_methods:
			var result = dbl.call(method_name)
			print("called ", StringName(method_name), " got ", result)
```

* First loop calls base object methods and clears dbl.__gutdbl_values
* If you comment out the first loop, the second loop runs and calls the methods on the double.


## Doubling abstract classes issue
__I think this has been resolved in 4.7beta1 or a little__


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

The logger could possibly add additional information when a return type error occurs and the script is a double.  This information should all be in the error code and stack trace.



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




# Changes
Godot 4.7 introduced more restrictive type checking for return values.  In prior releases Doubles could return `null` regardless of the declared return type of the function.  Doubles have been adjusted to return a default value for each `TYPE_` constant.  This may cause false postives/negatives in existing and new tests if you do not take this into account.

When a method is stubbed to return an invalid value GUT will generate an error but execution will continue.  This will result in an engine error as well.

Gut Error Example:
```
[GUT ERROR]:  Method [explicit_int_return] was stubbed to return invalid value [adsf].
```
Engine Error Example:
```
SCRIPT ERROR: Trying to return a value of type "String" from a function whose return type is "int".
```


## Methods with explict return types
These values are defined in `res://addons/gut/gut_constants.gd`.  There is no formal way to adjust these values yet, but you can if you really want to.  I would suggest doing this in a pre-run hook.
```gdscript
extends GutHookScript

func run():
    GutConstants.DEFAULT_RETURNS[TYPE_INT] = -99
```
The current values are:
```
static var DEFAULT_RETURNS = {
	TYPE_NIL : null,
	TYPE_BOOL : false,
	TYPE_INT : 0,
	TYPE_FLOAT : 0.0,
	TYPE_STRING : '',
	TYPE_VECTOR2 : Vector2.ZERO,
	TYPE_VECTOR2I : Vector2i.ZERO,
	TYPE_RECT2 : Rect2(0, 0, 0, 0),
	TYPE_RECT2I : Rect2i(0, 0, 0, 0),
	TYPE_VECTOR3 : Vector3.ZERO,
	TYPE_VECTOR3I : Vector3i.ZERO,
	TYPE_TRANSFORM2D : Transform2D.IDENTITY,
	TYPE_VECTOR4 : Vector4.ZERO,
	TYPE_VECTOR4I : Vector4i.ZERO,
	TYPE_PLANE : Plane.PLANE_XY,
	TYPE_QUATERNION : Quaternion.IDENTITY,
	TYPE_AABB : AABB(),
	TYPE_BASIS : Basis.IDENTITY,
	TYPE_TRANSFORM3D : Transform3D.IDENTITY,
	TYPE_PROJECTION : Projection.IDENTITY,
	TYPE_COLOR : Color.WHITE,
	TYPE_STRING_NAME : &'',
	TYPE_NODE_PATH : NodePath(),
	TYPE_RID : RID(),
	TYPE_OBJECT : null,
	TYPE_CALLABLE : Callable(),
	TYPE_SIGNAL : null,
	TYPE_DICTIONARY : {},
	TYPE_ARRAY : [],
	TYPE_PACKED_BYTE_ARRAY : PackedByteArray(),
	TYPE_PACKED_INT32_ARRAY : PackedInt32Array(),
	TYPE_PACKED_INT64_ARRAY : PackedInt64Array(),
	TYPE_PACKED_FLOAT32_ARRAY : PackedFloat32Array(),
	TYPE_PACKED_FLOAT64_ARRAY : PackedFloat64Array(),
	TYPE_PACKED_STRING_ARRAY : PackedStringArray(),
	TYPE_PACKED_VECTOR2_ARRAY : PackedVector2Array(),
	TYPE_PACKED_VECTOR3_ARRAY : PackedVector3Array(),
	TYPE_PACKED_COLOR_ARRAY : PackedColorArray(),
	TYPE_PACKED_VECTOR4_ARRAY : PackedVector4Array(),
	# TYPE_MAX : 'TYPE_MAX',
}
```