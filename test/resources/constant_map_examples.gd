class_name TestResourceConstantMapExamples
extends Object

const c_string = 'This is a string'
const c_int = 10
const c_preload_script = preload('res://test/unit/test_inner_class_registry.gd')
const c_preload_script_with_class_name = preload('res://addons/gut/utils.gd')

class InnerClassOne:
	var id = 'one'

class InnerClassTwo:
	var id = 'two'

	class InnerClassTwo_One:
		var id = 'two-one'

	class InnerClassTwo_Two:
		var id = 'two-two'

class InnerClassWithPreloadConstants:
	const c_preload_script = preload('res://test/unit/test_inner_class_registry.gd')
	const c_preload_script_with_class_name = preload('res://addons/gut/utils.gd')


