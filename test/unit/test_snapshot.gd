extends 'res://addons/gut/test.gd'


func test_UNRELATED():
	assert_almost_eq(1,1.0,0.1)

func test_create_snapshot_directory():
	var path = gut._snapshot_directory
	#removing snapshot directory
	var dir = Directory.new()
	if dir.dir_exists(path):
		if dir.open(path) == OK:
			dir.list_dir_begin(true)
			var file_name = dir.get_next()
			while file_name != "":
				if dir.current_is_dir():
					return _fail("Error cant destroy snapshot directory because contains a directory")
				else:
					dir.remove(file_name)
				file_name = dir.get_next()
		else:
			return _fail("Error cant destroy snapshot directory because can't open it")
	assert_false( dir.dir_exists(path))
	assert_matches_snapshot({})
	assert_true( dir.dir_exists(path))

func test_creates_snapshot_file():
	#remove file if exists <file_name>_<inner_class_name>_<test_name>_<X>.snapshot
	var path = "test_snapshot_test_creates_snapshot_file_0.snapshot"
	var file := File.new()
	if file.file_exists(path):
		var dir = Directory.new()
		if not dir.remove(path) == OK:
			return _fail("cant remove existing file")
		
	assert_file_does_not_exist(path)
	assert_matches_snapshot({})
	assert_file_exists(path)


func test_pure_dict_without_ints():
	assert_matches_snapshot(
		{
			my_float = 4.0,
			my_string = "a string",
			my_bool = true,
		}
	)

func test_pure_dict_with_ints():
	assert_matches_snapshot(
		{
			my_int = 5,
			my_float = 4.0,
			my_string = "a string",
			my_bool = true,
		}
	)


func test_nested_pure_dict_with_ints():
	pending()
	assert_matches_snapshot(
		{
			my_int = 5,
			my_float = 4.0,
			my_string = "a string",
			my_bool = true,
			my_dict = {
				inner_int = 5,
				inner_float = 4.0,
				inner_string = "a string",
				inner_bool = true,
				}
		}
	)





func test_class():
	pending()

	
class TestShouldFail:
	extends 'res://addons/gut/test.gd'
	
	func test_node_should_fail():
		var x = Position2D.new()
		x.position = Vector2.LEFT
		assert_matches_snapshot(x)

	func test_reference_should_fail():
		var x = Reference.new()
		assert_matches_snapshot(x)

	func test_dict_holding_ref_should_fail():
		assert_matches_snapshot({
							node = Node.new()
							})
	
	func test_inner_dict_holding_ref_should_fail():
		assert_matches_snapshot({
							my_float = 4.0,
							my_dict = {
								node = Node.new()
								}
							})
	func test_string_should_fail():
		assert_matches_snapshot("")
		

class TestAnyInnerClass:
	extends 'res://addons/gut/test.gd'
	
	#should not have the same count
	func test_it_works():
		assert_matches_snapshot({})

	func test_it_works_differently():
		assert_matches_snapshot({})
		assert_matches_snapshot({})
	
	func test_second_test_in_inner_class():
		assert_matches_snapshot({})
