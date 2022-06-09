extends Control
tool

var _interface = null
var _utils = load('res://addons/gut/utils.gd').get_instance()

func set_interface(which):
	_interface = which
	

func _ready():
	print('run results is ready')


func _open_file(path, line_number):
	if(_interface == null):
		print('Too soon, wait a bit and try again.')
		return
		
	var r = load(path)
	_interface.edit_script(r, line_number)
	

func _on_Button_pressed():
	_open_file('res://test/unit/test_print.gd', 27)



func load_json_results(path):
	var text = _utils.get_file_as_text(path)
	var j = JSON.parse(text).result
	
	print(j['test_scripts']['scripts'])
