class_name GutInternalTester

extends GutTest

const DOUBLE_ME_PATH = 'res://test/resources/doubler_test_objects/double_me.gd'
var DoubleMe = load(DOUBLE_ME_PATH)

const DOUBLE_ME_SCENE_PATH = 'res://test/resources/doubler_test_objects/double_me_scene.tscn'
var DoubleMeScene = load(DOUBLE_ME_SCENE_PATH)

const DOUBLE_EXTENDS_NODE2D = 'res://test/resources/doubler_test_objects/double_extends_node2d.gd'
var DoubleExtendsNode2D = load(DOUBLE_EXTENDS_NODE2D)

const DOUBLE_EXTENDS_WINDOW_DIALOG = 'res://test/resources/doubler_test_objects/double_extends_window_dialog.gd'
var DoubleExtendsWindowDialog = load(DOUBLE_EXTENDS_WINDOW_DIALOG)

const INNER_CLASSES_PATH = 'res://test/resources/doubler_test_objects/inner_classes.gd'
var InnerClasses = load(INNER_CLASSES_PATH)

var Gut = load('res://addons/gut/gut.gd')
var Test = load('res://addons/gut/test.gd')
var Logger = load('res://addons/gut/logger.gd')
var Spy = load('res://addons/gut/spy.gd')
var TestCollector = load('res://addons/gut/test_collector.gd')

func _init():
	load('res://addons/gut/utils.gd').get_instance()._test_mode = true

func assert_warn(obj, times=1):
	if(obj.has_method('get_logger')):
		var msg = str('Should have ', times, ' warnings.')
		assert_eq(obj.get_logger().get_warnings().size(), times, msg)
	else:
		_fail('Does not have get_logger method')

func assert_errored(obj, times=1):
	if(obj.has_method('get_logger')):
		var msg = str('Should have ', times, ' errors.')
		assert_eq(obj.get_logger().get_errors().size(), times, msg)
	elif(obj.get('logger') != null):
		var msg = str('Should have ', times, ' errors.')
		assert_eq(obj.logger.get_errors().size(), times, msg)
	else:
		_fail(str('Cannot assert_errored, ', obj, ' does not have get_logger method or logger property'))

func assert_deprecated(obj, times=1):
	if(obj.has_method('get_logger')):
		var msg = str('Should have ', times, ' deprecations.')
		assert_eq(obj.get_logger().get_deprecated().size(), times, msg)
	else:
		_fail('Does not have get_logger method')


func assert_has_logger(obj):
	assert_has_method(obj, 'get_logger')
	assert_has_method(obj, 'set_logger')
	if(obj.has_method('get_logger')):
		assert_not_null(obj.get_logger(), 'Default logger not null.')
		if(obj.has_method('set_logger')):
			var l = double(Logger).new()
			obj.set_logger(l)
			assert_eq(obj.get_logger(), l, 'Set/get works')

func get_error_count(obj):
	return obj.logger.get_errors().size()


func new_gut(print_sub_tests=false):
	var g = Gut.new()
	g.logger = _utils.Logger.new()
	if(print_sub_tests):
		g.log_level = 3
		g.logger.disable_all_printers(true)
		g.logger.disable_printer("terminal", false)
		g.logger._min_indent_level = 1
		g.logger.dec_indent()
		g.logger.set_indent_string('|##| ')
		g.logger.disable_formatting(!print_sub_tests)
	else:
		g.log_level = g.LOG_LEVEL_FAIL_ONLY
		g.logger.disable_all_printers(true)

	g._should_print_versions = false
	g._should_print_summary = false

	return g

# ----------------------------
# Not used yet, but will be used eventually

# func new_test():
# 	var t = GutTest.new()
# 	var logger = _utils.Logger.new()
# 	t.set_logger(logger)
# 	return t


# func new_test_double():
# 	var t = double(GutTest).new()
# 	var logger = double(_utils.Logger).new()
# 	stub(t, 'set_logger').to_call_super()
# 	stub(t, 'get_logger').to_call_super()
# 	t.set_logger(logger)
# 	return t
# ----------------------------