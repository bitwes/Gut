extends Node2D

var PanelControls = load('res://addons/gut/gui/panel_controls.gd')

var _save_load = PanelControls.SaveLoadControl.new('whatever', 1, 'hint')
func _ready():
	$PanelControls.add_child(_save_load)
	
	_save_load.dlg_load.show_diretory_types = false
	_save_load.dlg_load.show_user = false
	_save_load.dlg_save.show_os = false
	
