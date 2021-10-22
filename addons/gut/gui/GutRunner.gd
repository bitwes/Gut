extends Node2D

var Gut = load('res://addons/gut/gut.gd')
const RUNNER_JSON_PATH = 'res://.gut_editor_config.json'
const RESULT_FILE = 'user://.gut_editor.bbcode'

var _gut_config = load('res://addons/gut/gut_config.gd').new()
var _gut = null;
# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred('_setup_gut')


func _setup_gut():
	_gut = Gut.new()
	add_child(_gut)

	_gut_config.load_options(RUNNER_JSON_PATH)

	_gut.connect('tests_finished', self, '_on_tests_finished',
		[_gut_config.options.should_exit, _gut_config.options.should_exit_on_success])

	_gut_config.config_gut(_gut)

	var run_rest_of_scripts = _gut_config.options.unit_test_name == ''
	_gut.test_scripts(run_rest_of_scripts)


func _on_tests_finished(should_exit, should_exit_on_success):
	var content = _gut.get_gui().get_text_box().text

	var f = File.new()
	var result = f.open(RESULT_FILE, f.WRITE)
	if(result == OK):
		f.store_string(content)
		f.close()
	else:
		print('ERROR Could not save bbcode, result = ', result)

	if(should_exit):
		get_tree().quit()
	elif(should_exit_on_success and _gut.get_fail_count() == 0):
		get_tree().quit()
