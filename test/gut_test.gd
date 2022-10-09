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


func new_gut():
	var g = Gut.new()
	g._should_print_versions = false
	g.log_level = g.LOG_LEVEL_FAIL_ONLY
	return g
