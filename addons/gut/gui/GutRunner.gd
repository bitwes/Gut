extends Node2D

var Gut = load('res://addons/gut/gut.gd')
var ResultExporter = load('res://addons/gut/result_exporter.gd')
var GutConfig = load('res://addons/gut/gut_config.gd')

const RUNNER_JSON_PATH = 'res://.gut_editor_config.json'
const RESULT_FILE = 'user://.gut_editor.bbcode'
const RESULT_JSON = 'user://.gut_editor.json'

var _gut_config = null
var _gut = null;
var _wrote_results = false
# Flag for when this is being used at the command line.  Otherwise it is
# assumed this is being used by the panel and being launched with
# play_custom_scene
var _cmdln_mode = false

var _resolution = null
var _viewport_size = null
var _use_viewport = false
var _should_draw_outline = false


onready var _test_parent = $ColorRect/ViewportContainer/Viewport
onready var _color_rect = $ColorRect


func _ready():
	if(_gut_config == null):
		_gut_config = GutConfig.new()
		_gut_config.load_options(RUNNER_JSON_PATH)

	var viewport_option = _gut_config.options.viewport_size
	if(viewport_option != null and viewport_option[0] > 2 and viewport_option[1] > 2):
		_viewport_size = Vector2(viewport_option[0], viewport_option[1])

	var res_option = _gut_config.options.resolution
	if(res_option != null and res_option[0] > 2 and res_option[1] > 2):
		_resolution = Vector2(res_option[0], res_option[1])

	_use_viewport = _gut_config.options.use_viewport

	_color_rect.connect('draw', self, '_on_color_rect_draw')
	_setup_screen()

	# The command line will call run_tests on its own.  When used from the panel
	# we have to kick off the tests ourselves b/c there's no way I know of to
	# interact with the scene that was run via play_custom_scene.
	if(!_cmdln_mode):
		call_deferred('run_tests')



func _setup_screen():
	if(!_use_viewport):
		_color_rect.visible = false
		return

	_test_parent.size = _test_parent.get_parent().rect_size
	_color_rect.rect_position = Vector2(0, 0)
	_color_rect.color = _gut_config.options.viewport_bg_color

	if(_viewport_size == null):
		_viewport_size = get_tree().root.get_size_override()

	if(_resolution != null):
		if(_resolution.x < 200):
			_resolution.x = 200
		if(_resolution.y < 200):
			_resolution.y = 200
		get_tree().root.set_size_override(false, _resolution)
		OS.window_size = _resolution
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_DISABLED,  SceneTree.STRETCH_MODE_DISABLED, _resolution)
	else:
		_resolution = get_tree().root.get_size_override()

	if(_viewport_size != null):
		_color_rect.rect_size = _viewport_size
		_test_parent.size = _viewport_size


	if(_viewport_size.x < _resolution.x):
		_color_rect.rect_position.x = _resolution.x - _viewport_size.x - 5
		_color_rect.rect_position.y += 5
		_should_draw_outline = true
		_color_rect.update()


func _on_color_rect_draw():
	if(_should_draw_outline):

		var drect = _color_rect.get_rect()
		drect.position = Vector2(-2, -2)
		drect.size += Vector2(4, 4)
		_color_rect.draw_rect(drect, Color(1, 0, 0), false, 3)


func run_tests():
	if(_gut == null):
		_gut = Gut.new()

	if(_use_viewport):
		_gut.set_add_children_to(_test_parent)

	add_child(_gut)
	if(!_gut_config.options.gut_on_top):
		move_child(_gut, 0)

	if(!_cmdln_mode):
		_gut.connect('tests_finished', self, '_on_tests_finished',
			[_gut_config.options.should_exit, _gut_config.options.should_exit_on_success])

	_gut_config.config_gut(_gut)

	var run_rest_of_scripts = _gut_config.options.unit_test_name == ''
	_gut.test_scripts(run_rest_of_scripts)


func _write_results():
	# bbcode_text appears to be empty.  I'm not 100% sure why.  Until that is
	# figured out we have to just get the text which stinks.
	var content = _gut.get_gui().get_text_box().text

	var f = File.new()
	var result = f.open(RESULT_FILE, f.WRITE)
	if(result == OK):
		f.store_string(content)
		f.close()
	else:
		print('ERROR Could not save bbcode, result = ', result)

	var exporter = ResultExporter.new()
	var f_result = exporter.write_summary_file(_gut, RESULT_JSON)
	_wrote_results = true


func _exit_tree():
	if(!_wrote_results and !_cmdln_mode):
		_write_results()


func _on_tests_finished(should_exit, should_exit_on_success):
	_write_results()

	if(should_exit):
		get_tree().quit()
	elif(should_exit_on_success and _gut.get_fail_count() == 0):
		get_tree().quit()


func get_gut():
	if(_gut == null):
		_gut = Gut.new()
	return _gut

func set_gut_config(which):
	_gut_config = which

func set_cmdln_mode(is_it):
	_cmdln_mode = is_it

func set_viewport_size(s):
	_viewport_size = s

func set_resolution(r):
	_resolution = r

func set_use_viewport(should):
	_use_viewport = should
