extends GutTest


class ReturnTypes:
	func returns_packed_string_array()->PackedStringArray:
		var to_return = PackedStringArray()
		return to_return

	func returns_plane() -> Plane:
		return Plane.PLANE_XY

	func returns_dictionary() -> Dictionary:
		return {'a':'b'}

	func returns_vector2() -> Vector2:
		return Vector2(99, 99)

	func returns_color() -> Color:
		return Color.RED

	func returns_string() -> String:
		return "hello"

	func returns_string_name() -> StringName:
		return &"world"


func before_all():
	register_inner_classes(get_script())


func test_packed_string_array():
	var dbl = double(ReturnTypes).new()
	var result : PackedStringArray = dbl.returns_packed_string_array()
	result.append('a')

	var result_2 = dbl.returns_packed_string_array()
	assert_true(result_2.is_empty())

func test_packed_string_array_2():
	var dbl = double(ReturnTypes).new()
	var result : PackedStringArray = dbl.returns_packed_string_array()
	assert_true(result.is_empty())

func test_packed_string_array_3():
	var dbl = double(ReturnTypes).new()
	var result : PackedStringArray = dbl.returns_packed_string_array()
	result.append('a')

	dbl = double(ReturnTypes).new()
	var result_2 = dbl.returns_packed_string_array()
	assert_true(result_2.is_empty())


func test_it_plane():
	var dbl = double(ReturnTypes).new()
	var result : Plane = dbl.returns_plane()
	result.x = 99

	var result_2 = dbl.returns_plane()
	assert_true(result_2.x != 99)


func test_it_dictionary():
	var dbl = double(ReturnTypes).new()
	var result = dbl.returns_dictionary()
	result['a'] = 'b'

	var result_2 = dbl.returns_dictionary()
	assert_true(result_2.is_empty())


func test_vector2():
	var dbl = double(ReturnTypes).new()
	var result = dbl.returns_vector2()
	result.x = -1

	var result_2 = dbl.returns_vector2()
	assert_eq(result_2.x, 0.0)


func test_color():
	var dbl = double(ReturnTypes).new()
	var result = dbl.returns_color()
	result.g = .5

	var result_2 = dbl.returns_color()
	assert_eq(result_2.g, 1.0)

func test_string():
	var dbl = double(ReturnTypes).new()
	var result = dbl.returns_string()
	result = 'hello'

	var result_2 = dbl.returns_string()
	assert_eq(result_2, '')

func test_string_name():
	var dbl = double(ReturnTypes).new()
	var result = dbl.returns_string_name()
	result = 'hello'

	var result_2 = dbl.returns_string_name()
	assert_eq(result_2, '')

