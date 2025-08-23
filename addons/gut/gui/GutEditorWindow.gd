@tool
extends Window

var _bottom_panel = null
var gut_plugin = null


# --------
# Events
# --------
func _on_to_panel_pressed() -> void:
	gut_plugin.toggle_windowed()


func _on_on_top_toggled(toggled_on: bool) -> void:
	always_on_top = toggled_on


# --------
# Public
# --------
func add_gut_panel(panel : Control):
	$Layout.add_child(panel)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.visible = true
	_bottom_panel = panel


func remove_panel():
	$Layout.remove_child(_bottom_panel)
