@tool
extends EditorPlugin

var _bottom_panel = null


func _enter_tree():
	var es_config_path = 'Gut/config_path'
	var es_config_path_value = 'res://.gut_editor_config.json'
	var e_set = EditorInterface.get_editor_settings()
	if(e_set.has_setting(es_config_path)):
		es_config_path_value = e_set.get_setting(es_config_path)

	_bottom_panel = preload('res://addons/gut/gui/GutBottomPanel.tscn').instantiate()
	_bottom_panel.set_config_path(es_config_path_value)

	var button = add_control_to_bottom_panel(_bottom_panel, 'GUT')
	button.shortcut_in_tooltip = true

	await get_tree().create_timer(3).timeout
	_bottom_panel.set_interface(get_editor_interface())
	_bottom_panel.set_plugin(self)
	_bottom_panel.set_panel_button(button)
	_bottom_panel.load_shortcuts()


func _exit_tree():
	# Clean-up of the plugin goes here
	# Always remember to remove_at it from the engine when deactivated
	remove_control_from_bottom_panel(_bottom_panel)
	_bottom_panel.free()
