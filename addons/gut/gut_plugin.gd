tool
extends EditorPlugin

var _bottom_panel = null

func _enter_tree():
    _bottom_panel = preload('res://addons/gut/gui/GutBottomPanel.tscn').instance()
    # Initialization of the plugin goes here
    # Add the new type with a name, a parent type, a script and an icon
    add_custom_type("Gut", "Control", preload("plugin_control.gd"), preload("icon.png"))

    _bottom_panel._interface = get_editor_interface()
    _bottom_panel._gut_plugin = self
    add_control_to_bottom_panel(_bottom_panel, 'GUT')


func _exit_tree():
    # Clean-up of the plugin goes here
    # Always remember to remove it from the engine when deactivated
    remove_custom_type("Gut")
    remove_control_from_bottom_panel(_bottom_panel)
    _bottom_panel.free()
