class_name GutConstants

const TYPE_STRINGS = {
	TYPE_NIL : 'TYPE_NIL',
	TYPE_BOOL : 'TYPE_BOOL',
	TYPE_INT : 'TYPE_INT',
	TYPE_FLOAT : 'TYPE_FLOAT',
	TYPE_STRING : 'TYPE_STRING',
	TYPE_VECTOR2 : 'TYPE_VECTOR2',
	TYPE_VECTOR2I : 'TYPE_VECTOR2I',
	TYPE_RECT2 : 'TYPE_RECT2',
	TYPE_RECT2I : 'TYPE_RECT2I',
	TYPE_VECTOR3 : 'TYPE_VECTOR3',
	TYPE_VECTOR3I : 'TYPE_VECTOR3I',
	TYPE_TRANSFORM2D : 'TYPE_TRANSFORM2D',
	TYPE_VECTOR4 : 'TYPE_VECTOR4',
	TYPE_VECTOR4I : 'TYPE_VECTOR4I',
	TYPE_PLANE : 'TYPE_PLANE',
	TYPE_QUATERNION : 'TYPE_QUATERNION',
	TYPE_AABB : 'TYPE_AABB',
	TYPE_BASIS : 'TYPE_BASIS',
	TYPE_TRANSFORM3D : 'TYPE_TRANSFORM3D',
	TYPE_PROJECTION : 'TYPE_PROJECTION',
	TYPE_COLOR : 'TYPE_COLOR',
	TYPE_STRING_NAME : 'TYPE_STRING_NAME',
	TYPE_NODE_PATH : 'TYPE_NODE_PATH',
	TYPE_RID : 'TYPE_RID',
	TYPE_OBJECT : 'TYPE_OBJECT',
	TYPE_CALLABLE : 'TYPE_CALLABLE',
	TYPE_SIGNAL : 'TYPE_SIGNAL',
	TYPE_DICTIONARY : 'TYPE_DICTIONARY',
	TYPE_ARRAY : 'TYPE_ARRAY',
	TYPE_PACKED_BYTE_ARRAY : 'TYPE_PACKED_BYTE_ARRAY',
	TYPE_PACKED_INT32_ARRAY : 'TYPE_PACKED_INT32_ARRAY',
	TYPE_PACKED_INT64_ARRAY : 'TYPE_PACKED_INT64_ARRAY',
	TYPE_PACKED_FLOAT32_ARRAY : 'TYPE_PACKED_FLOAT32_ARRAY',
	TYPE_PACKED_FLOAT64_ARRAY : 'TYPE_PACKED_FLOAT64_ARRAY',
	TYPE_PACKED_STRING_ARRAY : 'TYPE_PACKED_STRING_ARRAY',
	TYPE_PACKED_VECTOR2_ARRAY : 'TYPE_PACKED_VECTOR2_ARRAY',
	TYPE_PACKED_VECTOR3_ARRAY : 'TYPE_PACKED_VECTOR3_ARRAY',
	TYPE_PACKED_COLOR_ARRAY : 'TYPE_PACKED_COLOR_ARRAY',
	TYPE_PACKED_VECTOR4_ARRAY : 'TYPE_PACKED_VECTOR4_ARRAY',
	TYPE_MAX : 'TYPE_MAX',
}

# Values should not be referenced outside of this script.
# Use get_default_return_value.  The functions look weird, but they are here
# so that each call to a doubled method returns a unique instance of things.
static var _default_returns = {
	TYPE_NIL : null,
	TYPE_BOOL : false,
	TYPE_INT : 0,
	TYPE_FLOAT : 0.0,
	TYPE_STRING : '',
	TYPE_VECTOR2 : Vector2.ZERO,
	TYPE_VECTOR2I : Vector2i.ZERO,
	TYPE_RECT2 : func(): return Rect2(0, 0, 0, 0),
	TYPE_RECT2I : func(): return Rect2i(0, 0, 0, 0),
	TYPE_VECTOR3 : Vector3.ZERO,
	TYPE_VECTOR3I : Vector3i.ZERO,
	TYPE_TRANSFORM2D : Transform2D.IDENTITY,
	TYPE_VECTOR4 : Vector4.ZERO,
	TYPE_VECTOR4I : Vector4i.ZERO,
	TYPE_PLANE : Plane.PLANE_XY,
	TYPE_QUATERNION : Quaternion.IDENTITY,
	TYPE_AABB : func(): return AABB(),
	TYPE_BASIS : Basis.IDENTITY,
	TYPE_TRANSFORM3D : Transform3D.IDENTITY,
	TYPE_PROJECTION : Projection.IDENTITY,
	TYPE_COLOR : Color.WHITE,
	TYPE_STRING_NAME : &'',
	TYPE_NODE_PATH : func(): return NodePath(),
	TYPE_RID : func(): return RID(),
	TYPE_OBJECT : null,
	TYPE_CALLABLE : func(): return Callable(),
	TYPE_SIGNAL : null,
	TYPE_DICTIONARY : func(): return {},
	TYPE_ARRAY : func(): return [],
	TYPE_PACKED_BYTE_ARRAY : func(): return PackedByteArray(),
	TYPE_PACKED_INT32_ARRAY : func(): return PackedInt32Array(),
	TYPE_PACKED_INT64_ARRAY : func(): return PackedInt64Array(),
	TYPE_PACKED_FLOAT32_ARRAY : func(): return PackedFloat32Array(),
	TYPE_PACKED_FLOAT64_ARRAY : func(): return PackedFloat64Array(),
	TYPE_PACKED_STRING_ARRAY : func(): return PackedStringArray(),
	TYPE_PACKED_VECTOR2_ARRAY : func(): return PackedVector2Array(),
	TYPE_PACKED_VECTOR3_ARRAY : func(): return PackedVector3Array(),
	TYPE_PACKED_COLOR_ARRAY : func(): return PackedColorArray(),
	TYPE_PACKED_VECTOR4_ARRAY : func(): return PackedVector4Array(),
	# TYPE_MAX : 'TYPE_MAX',
}

# Seeded with any type constant where the constant name can't be converted to
# a string using pascal case and/or the values need manual conversion.  The
# rest are added in _static_init.
static var TYPE_KEYWORDS = {
	TYPE_NIL : 'null',
	TYPE_BOOL : 'bool',
	TYPE_INT : 'int',
	TYPE_FLOAT : 'float',
}


static var NOT_SET := &"___NOT__SET___"


static func _static_init() -> void:
	for key in TYPE_STRINGS:
		if(!TYPE_KEYWORDS.has(key)):
			var n : String = TYPE_STRINGS[key].to_lower()
			n = n.lstrip("type_")
			TYPE_KEYWORDS[key] = n.to_pascal_case()


static func is_not_set(val):
	return typeof(val) == TYPE_STRING_NAME and val == NOT_SET


static func get_default_return_value(type=null):
	if(type == null or typeof(type) != TYPE_INT):
		return null
	var to_return = null
	if(is_not_set(type)):
		to_return = null
	elif(_default_returns.has(type)):
		to_return = _default_returns[type]
		if(to_return is Callable):
			to_return = to_return.call()

	return to_return