extends "res://addons/gut/test.gd"

var Gut = load('res://addons/gut/gut.gd')
var Test = load('res://addons/gut/test.gd')
var StubParams = load('res://addons/gut/stub_params.gd')

const DOUBLE_ME_PATH = 'res://test/resources/doubler_test_objects/double_me.gd'
const DOUBLE_ME_SCENE_PATH = 'res://test/resources/doubler_test_objects/double_me_scene.tscn'

func test_can_get_stubber():
	var g = Gut.new()
	assert_ne(g.get_stubber(), null)

# ---------------------------------
# these two tests use the gut instance that is passed to THIS test.  This isn't
# PURE testing but it appears to cover the bases ok.
# ------
func test_stubber_cleared_between_tests_setup():
	var sp = StubParams.new('thing', 'method').to_return(5)
	gut.get_stubber().add_stub(sp)
	gut.p('this sets up for next test')

func test_stubber_cleared_between_tests():
	assert_eq(gut.get_stubber().get_return('thing', 'method'), null)
# ---------------------------------

func test_can_get_doubler():
	var g = Gut.new()
	assert_ne(g.get_doubler(), null)

func test_doublers_stubber_is_guts_stubber():
	var g = Gut.new()
	assert_eq(g.get_doubler().get_stubber(), g.get_stubber())

# Since the stubber and doubler are "global" to gut, this is the best place
# to test this so that the _double_count in the doubler isn't reset which
# causes some super confusing side effects.
func test_can_stub_scene_script_and_scene_at_same_time():
	var script_path = DOUBLE_ME_SCENE_PATH.replace('.tscn', '.gd')

	var scene = double_scene(DOUBLE_ME_SCENE_PATH).instantiate()
	var script = double(script_path).new()

	stub(DOUBLE_ME_SCENE_PATH, 'return_hello').to_return('scene')
	stub(script_path, 'return_hello').to_return('script')

	assert_eq(scene.return_hello(), 'scene')
	assert_eq(script.return_hello(), 'script')
