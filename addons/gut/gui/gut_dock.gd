extends EditorDock


var _panel : Control = null
var _current_layout = -1


func _update_layout(layout):
	_current_layout = layout
	if(_panel != null):
		if(layout == DOCK_LAYOUT_FLOATING):
			_windowed_mode()
		else:
			_dock_mode()


# -------------
# Private
# -------------
func _windowed_mode():
	_panel.show_layout_buttons(true)


func _dock_mode():
	_panel.results_horiz_layout()
	_panel.show_layout_buttons(false)


# -------------
# Public
# -------------
func add_bottom_panel(gut_bottom_panel):
	_panel = gut_bottom_panel
	# Make floating button not supported right now
	add_child(_panel)
	_panel.make_floating_btn.visible = false
	_update_layout(_current_layout)
