extends Node2D
const RUNNER_JSON_PATH = 'res://.gut_editor_config.json'
var GutConfigGui = load('res://addons/gut/gui/gut_config_gui.gd')

@onready var _ctrls = {
	settings = $ColorRect/ScrollContainer/Settings
}

var _gut_config = load('res://addons/gut/gut_config.gd').new()
var _gut_config_gui = null

# Called when the node enters the scene tree for the first time.
func _ready():
	_gut_config.load_panel_options(RUNNER_JSON_PATH)
	_gut_config_gui = GutConfigGui.new(_ctrls.settings)
	_gut_config_gui.set_options(_gut_config.options)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
