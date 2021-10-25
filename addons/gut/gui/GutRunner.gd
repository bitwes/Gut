extends Node2D

var Gut = load('res://addons/gut/gut.gd')
var ResultExporter = load('res://addons/gut/result_exporter.gd')

const RUNNER_JSON_PATH = 'res://.gut_editor_config.json'
const RESULT_FILE = 'user://.gut_editor.bbcode'
const RESULT_JSON = 'user://.gut_editor.json'

var _gut_config = load('res://addons/gut/gut_config.gd').new()
var _gut = null;
var _wrote_results = false

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
	if(!_wrote_results):
		_write_results()


func _on_tests_finished(should_exit, should_exit_on_success):
	_write_results()

	if(should_exit):
		get_tree().quit()
	elif(should_exit_on_success and _gut.get_fail_count() == 0):
		get_tree().quit()
