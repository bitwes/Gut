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
func return_plane() -> Plane:
	return Plane.PLANE_YZ

# TYPE_QUATERNION : Quaternion.IDENTITY,
func return_quaternion()->Quaternion:
	return Quaternion()

# TYPE_AABB : AABB(),
func return_aabb() -> AABB:
	var aabb = AABB()
	aabb.end = Vector3(1, 1, 1)
	return aabb

# TYPE_BASIS : Basis.IDENTITY,
func return_basis() -> Basis:
	return Basis.FLIP_X

# TYPE_TRANSFORM3D : Transform3D.IDENTITY,
func return_transform_3d() -> Transform3D:
	return Transform3D.FLIP_X

# TYPE_PROJECTION : Projection.IDENTITY,
func return_projection() -> Projection:
	return Projection.ZERO

# TYPE_COLOR : Color.WHITE,
func return_color()->Color:
	return Color(.1, .2, .3, .4)

# TYPE_STRING_NAME : &'',
func return_string_name() -> StringName:
	return &'goodbye blue sky'

# TYPE_NODE_PATH : NodePath(),
func return_node_path() ->NodePath:
	return NodePath('a/b')

# TYPE_RID : RID(),
func return_rid() -> RID:
	return rid_from_int64(3)

# TYPE_OBJECT : null,
func return_object() -> Object:
	return Resource.new()

# TYPE_CALLABLE : null,
func return_callable() -> Callable:
	return Callable()

# TYPE_SIGNAL : null,
func return_signal() -> Signal:
	return Signal()

# TYPE_DICTIONARY : {},
func return_dictionary() -> Dictionary:
	return {foo = 'bar'}

# TYPE_ARRAY : [],
func return_array() -> Array:
	return [1, 2, 'three']

# TYPE_PACKED_BYTE_ARRAY : PackedByteArray(),
func return_packed_byte_array()->PackedByteArray:
	return PackedByteArray()

# TYPE_PACKED_INT32_ARRAY : PackedInt32Array(),
func return_packed_int32_array()->PackedInt32Array:
	return PackedInt32Array()

# TYPE_PACKED_INT64_ARRAY : PackedInt64Array(),
func return_packed_int64_array() -> PackedInt64Array:
	return PackedInt64Array()

# TYPE_PACKED_FLOAT32_ARRAY : PackedFloat32Array(),
func return_packed_float32_array() -> PackedFloat32Array:
	return PackedFloat32Array()

# TYPE_PACKED_FLOAT64_ARRAY : PackedFloat64Array(),
func return_packed_float64_array() -> PackedFloat64Array:
	return PackedFloat64Array()

# TYPE_PACKED_STRING_ARRAY : PackedStringArray(),
func return_packed_string_array() -> PackedStringArray:
	return PackedStringArray()

# TYPE_PACKED_VECTOR2_ARRAY : PackedVector2Array(),
func return_packed_vector2_array() -> PackedVector2Array:
	return PackedVector2Array()

# TYPE_PACKED_VECTOR3_ARRAY : PackedVector3Array(),
func return_packed_vector3_array() -> PackedVector3Array:
	return PackedVector3Array()

# TYPE_PACKED_COLOR_ARRAY : PackedColorArray(),
func return_packed_color_array()->PackedColorArray:
	return PackedColorArray([Color.BLUE])

# TYPE_PACKED_VECTOR4_ARRAY : PackedVector4Array(),
func return_packed_vector4_array() -> PackedVector4Array:
	return PackedVector4Array([Vector4.ONE, Vector4.ZERO])
