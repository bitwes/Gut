@tool
extends Window


var GutEditorGlobals = load('res://addons/gut/gui/editor_globals.gd')

@onready var _chk_always_on_top = $Layout/WinControls/OnTop

var _bottom_panel = null
var _ready_to_go = false

var gut_plugin = null
var interface = null
var _menu_manager = null

func _notification(what: int) -> void:
	if(what == NOTIFICATION_PREDELETE):
		_menu_manager._signaler = null
		_menu_manager = null


func _ready() -> void:
	var pref_size = GutEditorGlobals.user_prefs.gut_window_size.value
	if(pref_size.x < 0):
		size = Vector2(800, 800)
	else:
		size = pref_size
	always_on_top = GutEditorGlobals.user_prefs.gut_window_on_top.value
	_chk_always_on_top.button_pressed = always_on_top



# --------
# Events
# --------
func _on_on_top_toggled(toggled_on: bool) -> void:
	always_on_top = toggled_on
	GutEditorGlobals.user_prefs.gut_window_on_top.value = toggled_on


func _on_size_changed() -> void:
	if(_ready_to_go):
		GutEditorGlobals.user_prefs.gut_window_size.value = size


func _on_close_requested() -> void:
	gut_plugin.toggle_windowed()


# --------
# Public
# --------
func shadow_menu_manager(which, shortcuts_dialog):
	var menu_bar = $Layout/WinControls/MenuBar
	_menu_manager = load('res://addons/gut/menu_manager.gd').new()
	menu_bar.add_child(_menu_manager.sub_menu)
	menu_bar.set_menu_title(0, "GUT")
	_menu_manager.shadow_menu(which)
	_menu_manager.apply_gut_shortcuts(shortcuts_dialog)


func add_gut_panel(panel : Control):
	$Layout.add_child(panel)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.visible = true
	_bottom_panel = panel
	_ready_to_go = true

	panel.owner = self

	# This stunk to figure out.
	theme = interface.get_editor_theme()
	var settings = interface.get_editor_settings()
	$ColorRect.color = settings.get_setting("interface/theme/base_color")


func remove_panel():
	$Layout.remove_child(_bottom_panel)
	_bottom_panel.owner = null



