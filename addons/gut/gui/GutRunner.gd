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
var _cmdln_mode = false

var _resolution = null
var _viewport_size = null


onready var _test_parent = $ColorRect/ViewportContainer/Viewport
onready var _color_rect = $ColorRect


func _ready():
	_setup_screen()
	call_deferred('_setup_gut')


func _setup_screen():
	_test_parent.size = _test_parent.get_parent().rect_size
	_color_rect.rect_position = Vector2(0, 0)

	if(_viewport_size == null):
		_viewport_size = get_tree().root.get_size_override()

	if(_resolution != null):
		get_tree().root.set_size_override(true, _resolution)
	else:
		_resolution = get_tree().root.get_size_override()

	if(_viewport_size != null):
		_color_rect.rect_size = _viewport_size
		_test_parent.size = _viewport_size

	if(_viewport_size.x < _resolution.x):
		_color_rect.rect_position.x = _resolution.x - _viewport_size.x - 5
		_color_rect.rect_position.y += 5


func _draw():
	var drect = _color_rect.get_rect()
	drect.position -= Vector2(2, 2)
	drect.size += Vector2(2, 2)
	draw_rect(drect, Color(1, 0, 0), false, 3)


func _setup_gut():
	if(_gut == null):
		_gut = Gut.new()
	_gut.set_add_children_to(_test_parent)
	add_child(_gut)

	if(_gut_config == null):
		_gut_config = GutConfig.new()
		_gut_config.load_options(RUNNER_JSON_PATH)

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