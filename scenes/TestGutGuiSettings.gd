extends Node2D
const RUNNER_JSON_PATH = 'user://test_gut_editor_config.json'
var GutConfigGui = load('res://addons/gut/gui/gut_config_gui.gd')

@onready var _ctrls = {
	settings = $ColorRect/ScrollContainer/Settings
}

var _gut_config = load('res://addons/gut/gut_config.gd').new()
var _gut_config_gui = null
var _settings_vbox = null

# Called when the node enters the scene tree for the first time.
func _ready():
	_settings_vbox = _ctrls.settings.duplicate()
	_gut_config.load_panel_options(RUNNER_JSON_PATH)
	_create_options()

func _clear_options():
	if(_gut_config_gui != null):
		var to_free = _ctrls.settings
		var new_one = _settings_vbox.duplicate()
		to_free.free()
		_ctrls.settings = new_one
		$ColorRect/ScrollContainer.add_child(_ctrls.settings)
	

func _create_options():
	_gut_config_gui = GutConfigGui.new(_ctrls.settings)
	_gut_config_gui.set_options(_gut_config.options, RUNNER_JSON_PATH)	

func save_options():
	_gut_config.options = _gut_config_gui.get_options(_gut_config.options)
	var w_result = _gut_config.write_options(RUNNER_JSON_PATH)
	if(w_result != OK):
		push_error(str('Could not write options to ', RUNNER_JSON_PATH, ': ', w_result))


func _on_save_pressed():
	save_options()
	print('saved')

func _on_load_pressed():
	_clear_options()
	await get_tree().create_timer(.5).timeout
	_create_options()
	print('loaded')
