extends "res://addons/gut/test.gd"

var Gut = load('res://addons/gut/gut.gd')
var Test = load('res://addons/gut/test.gd')

const TEMP_FILES = 'user://test_doubler_temp_file'

const DOUBLE_ME_PATH = 'res://test/doubler_test_objects/double_me.gd'
const DOUBLE_ME_SCENE_PATH = 'res://test/doubler_test_objects/double_me_scene.tscn'


var gr = {
	gut = null,
	test = null
}

func before_each():
	gr.gut = Gut.new()
	gr.test = Test.new()
	gr.test.gut = gr.gut

func after_each():
	gr.gut.get_doubler().clear_output_directory()
	gr.gut.get_spy().clear()

func test_double_returns_a_class():
	var D = gr.test.double(DOUBLE_ME_PATH)
	assert_ne(D.new(), null)

func test_double_sets_stubber_for_doubled_class():
	var d = gr.test.double(DOUBLE_ME_PATH).new()
	assert_eq(d.__gut_metadata_.stubber, gr.gut.get_stubber())

func test_basic_double_and_stub():
	var d = gr.test.double(DOUBLE_ME_PATH).new()
	gr.test.stub(DOUBLE_ME_PATH, 'get_value').to_return(10)
	assert_eq(d.get_value(), 10)

func test_get_set_double_strat():
	assert_accessors(gr.test, 'double_strategy', DOUBLE_STRATEGY.PARTIAL, DOUBLE_STRATEGY.FULL)

func test_when_strategy_is_full_then_supers_are_spied():
	var doubled = gr.test.double(DOUBLE_ME_PATH, DOUBLE_STRATEGY.FULL).new()
	doubled.is_blocking_signals()
	gr.test.assert_called(doubled, 'is_blocking_signals')
	assert_eq(gr.test.get_pass_count(), 1)

func test_when_strategy_is_partial_then_supers_are_NOT_spied_in_scripts():
	var doubled = gr.test.double(DOUBLE_ME_PATH, DOUBLE_STRATEGY.PARTIAL).new()
	doubled.is_blocking_signals()
	gr.test.assert_not_called(doubled, 'is_blocking_signals')
	assert_eq(gr.test.get_pass_count(), 1)

func test_can_override_strategy_when_doubling_scene():
	var doubled = gr.test.double_scene(DOUBLE_ME_SCENE_PATH, DOUBLE_STRATEGY.FULL).instance()
	doubled.is_blocking_signals()
	gr.test.assert_called(doubled, 'is_blocking_signals')
	assert_eq(gr.test.get_pass_count(), 1)

func test_when_strategy_is_partial_then_supers_are_NOT_spied_in_scenes():
	var doubled = gr.test.double_scene(DOUBLE_ME_SCENE_PATH, DOUBLE_STRATEGY.PARTIAL).instance()
	doubled.is_blocking_signals()
	gr.test.assert_not_called(doubled, 'is_blocking_signals')
	assert_eq(gr.test.get_pass_count(), 1)
