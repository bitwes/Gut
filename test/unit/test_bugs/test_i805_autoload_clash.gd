extends GutTest

class TestMakingScriptsWithAutoloadName:
	extends GutTest

	var DynScript = GutUtils.DynamicGdScript.new()

	func before_all():
		DynScript.default_script_name_no_extension = 'TestMakingScriptsWithAutoloadName'


	func test_enum():
		var src ="""
		enum ThisSpecialName{
			ONE,
			TWO,
			THREE
		}
		"""
		var Created = DynScript.create_script_from_source(src)
		var inst = Created.new()
		assert_not_null(inst)

	func test_class():
		var src ="""
		class ThisSpecialName:
			var foo = 'bar'
		"""
		var Created = DynScript.create_script_from_source(src)
		var inst = Created.new()
		assert_not_null(inst)

	func test_var():
		var src ="""
		var ThisSpecialName = 'foobar'
		"""
		var Created = DynScript.create_script_from_source(src)
		var inst = Created.new()
		assert_not_null(inst)

	func test_class_name():
		var src ="""
		class_name ThisSpecialName

		var foo = 'bar'
		"""
		var Created = DynScript.create_script_from_source(src)
		var inst = Created.new()
		assert_not_null(inst)

	func test_static_var():
		var src ="""
		static var ThisSpecialName = 'foo'
		"""
		var Created = DynScript.create_script_from_source(src)
		var inst = Created.new()
		assert_not_null(inst)


class TestMakingScriptsWithOptionName:
	extends GutTest

	var DynScript = GutUtils.DynamicGdScript.new()
	var OptParse = load("res://addons/gut/cli/optparse.gd")

	func before_all():
		DynScript.default_script_name_no_extension = 'TestMakingScriptsWithOptionName'


	func test_enum():
		var src ="""
		enum Options{
			ONE,
			TWO,
			THREE
		}
		"""
		var Created = DynScript.create_script_from_source(src)
		var inst = Created.new()
		assert_not_null(inst)


	func test_class():
		var src ="""
		class Options:
			var foo = 'bar'
		"""
		var Created = DynScript.create_script_from_source(src)
		var inst = Created.new()
		assert_not_null(inst)


	func test_var():
		var src ="""
		var Options = 'foobar'
		"""
		var Created = DynScript.create_script_from_source(src)
		var inst = Created.new()
		assert_not_null(inst)


	func test_class_name():
		var src ="""
		class_name Options

		var foo = 'bar'
		"""
		var Created = DynScript.create_script_from_source(src)
		var inst = Created.new()
		assert_not_null(inst)

	func test_static_var():
		var src ="""
		static var Options = 'foo'
		"""
		var Created = DynScript.create_script_from_source(src)
		var inst = Created.new()
		assert_not_null(inst)

	func test_inner_class_of_existing_class_name():
		var src ="""
		class GutTrackedError:
			var foo = 'bar'
		"""
		var Created = DynScript.create_script_from_source(src)
		var inst = Created.new()
		assert_not_null(inst)
