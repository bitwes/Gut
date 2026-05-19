class_name TestResourceAllReturnTypes


# TYPE_NIL : null,
func return_void() -> void:
	pass
# TYPE_BOOL : false,
func return_bool() -> bool:
	return true
# TYPE_INT : 0,
func return_int() -> int:
	return 99
# TYPE_FLOAT : 0.0,
func return_float() -> float:
	return 99.9
# TYPE_STRING : '',
func return_string() -> String:
	return 'hello world'
# TYPE_VECTOR2 : Vector2.ZERO,
func return_vector_2()->Vector2:
	return Vector2(99.9, 99.9)
# TYPE_VECTOR2I : Vector2i.ZERO,
func return_vector_2_i() -> Vector2i:
	return Vector2i(99, 99)
# TYPE_RECT2 : Rect2(0, 0, 0, 0),
func return_rect_2() ->Rect2:
	return Rect2(9.9, 9.9, 99.9, 99.9)
# TYPE_RECT2I : Rect2i(0, 0, 0, 0),
func return_rect_2_i() ->Rect2i:
	return Rect2i(9, 9, 99, 99)
# TYPE_VECTOR3 : Vector3.ZERO,
func return_vector_3() -> Vector3:
	return Vector3(99.9, 99.9, 99.9)
# TYPE_VECTOR3I : Vector3i.ZERO,
func return_vector_3i() -> Vector3i:
	return Vector3(99, 99, 99)
# TYPE_TRANSFORM2D : Transform2D.IDENTITY,
func return_transform_2d() -> Transform2D:
	return Transform2D.FLIP_X
# TYPE_VECTOR4 : Vector4.ZERO,
func return_vector_4() -> Vector4:
	return Vector4(99.9, 99.9, 99.9, 99.9)
# TYPE_VECTOR4I : Vector4i.ZERO,
func return_vector_4i() -> Vector4i:
	return Vector4i(99, 99, 99, 99)
# TYPE_PLANE : Plane.PLANE_XY,
# TYPE_QUATERNION : Quaternion.IDENTITY,
# TYPE_AABB : AABB(),
# TYPE_BASIS : Basis.IDENTITY,
# TYPE_TRANSFORM3D : Transform3D.IDENTITY,
# TYPE_PROJECTION : Projection.IDENTITY,
# TYPE_COLOR : Color.WHITE,
func return_color()->Color:
	return Color(.1, .2, .3, .4)
# TYPE_STRING_NAME : &'',
func return_string_name() -> StringName:
	return &'goodbye blue sky'
# TYPE_NODE_PATH : NodePath(),
# TYPE_RID : RID(),
# TYPE_OBJECT : null,
func return_object() -> Object:
	return Resource.new()
# TYPE_CALLABLE : null,
# TYPE_SIGNAL : null,
# TYPE_DICTIONARY : {},
func return_dictionary() -> Dictionary:
	return {foo = 'bar'}
# TYPE_ARRAY : [],
# TYPE_PACKED_BYTE_ARRAY : PackedByteArray(),
# TYPE_PACKED_INT32_ARRAY : PackedInt32Array(),
# TYPE_PACKED_INT64_ARRAY : PackedInt64Array(),
# TYPE_PACKED_FLOAT32_ARRAY : PackedFloat32Array(),
# TYPE_PACKED_FLOAT64_ARRAY : PackedFloat64Array(),
# TYPE_PACKED_STRING_ARRAY : PackedStringArray(),
# TYPE_PACKED_VECTOR2_ARRAY : PackedVector2Array(),
# TYPE_PACKED_VECTOR3_ARRAY : PackedVector3Array(),
# TYPE_PACKED_COLOR_ARRAY : PackedColorArray(),
func return_packed_color_array()->PackedColorArray:
	return PackedColorArray([Color.BLUE])
# TYPE_PACKED_VECTOR4_ARRAY : PackedVector4Array(),
