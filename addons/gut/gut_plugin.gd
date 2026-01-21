@tool
extends EditorPlugin

var VersionConversion = load("res://addons/gut/version_conversion.gd")
var MenuManager = load("res://addons/gut/gut_menu.gd")
var BottomPanelScene = preload('res://addons/gut/gui/GutBottomPanel.tscn')
var GutEditorGlobals = load('res://addons/gut/gui/editor_globals.gd')
var GutDock = load('res://addons/gut/gui/gut_dock.gd')

var _bottom_panel : Control = null
var _menu_mgr = null
var _gut_button = null
var _gut_window = null
var _dock_mode = 'none'
var _gut_dock = null


func _init():
	if(VersionConversion.error_if_not_all_classes_imported()):
		return


func _enter_tree():
	if(!_version_conversion()):
		return

	_bottom_panel = BottomPanelScene.instantiate()
	gut_as_panel()

	# ---------
	# I removed this delay because it was causing issues with the shortcut button.
	# The shortcut button wouldn't work right until load_shortcuts is called., but
	# the delay gave you 3 seconds to click it before they were loaded.  This
	# await came with the conversion to 4 and probably isn't needed anymore.
	# I'm leaving it here becuase I don't know why it showed up to begin with
	# and if it's needed, it will be pretty hard to debug without seeing this.
	#
	# This should be deleted after the next release or two if not needed.
	# UPDATE:
	# I added it back in when doing the window stuff.  Starting in a window
	# made it angry (don't remember how) until I added it back in.
	await get_tree().create_timer(1).timeout
	# ---

	_bottom_panel.set_interface(get_editor_interface())
	_bottom_panel.set_plugin(self)
	_bottom_panel.load_shortcuts()

	_menu_mgr = MenuManager.new()
	_bottom_panel._ctrls.run_at_cursor.menu_manager = _menu_mgr
	_bottom_panel.menu_manager = _menu_mgr
	add_tool_submenu_item("GUT", _menu_mgr.sub_menu)

	GutEditorGlobals.gut_plugin = self



func _version_conversion():
	var EditorGlobals = load("res://addons/gut/gui/editor_globals.gd")
	EditorGlobals.create_temp_directory()

	if(VersionConversion.error_if_not_all_classes_imported()):
		return false

	VersionConversion.convert()
	return true


func gut_as_panel():
	_gut_dock = GutDock.new()

	_gut_dock.title = "GUT"

	_gut_dock.default_slot = DOCK_SLOT_BOTTOM
	_gut_dock.set_global(false);
	_gut_dock.set_available_layouts(EditorDock.DOCK_LAYOUT_HORIZONTAL | EditorDock.DOCK_LAYOUT_FLOATING);

	add_dock(_gut_dock)
	_gut_dock.add_bottom_panel(_bottom_panel)
	_gut_dock.dock_shortcut = _bottom_panel.get_panel_shortcut()


func toggle_windowed():
	push_warning("You have to right click the GUT tab and choos 'floating'.  I cannot do this from a menu anymore.")


func _exit_tree():
	remove_tool_menu_item("GUT")
	_menu_mgr = null
	GutEditorGlobals.user_prefs.save_it()

	_bottom_panel.menu_manager = null

	remove_dock(_gut_dock)
	_gut_dock.queue_free()
	remove_tool_menu_item("GUT") # made by _menu_mgr


func show_output_panel():
	if(_gut_dock == null or !_gut_dock.is_inside_tree()):
		return

	var panel = null
	var kids = _gut_dock.get_parent().get_children()
	var idx = 0

	while(idx < kids.size() and panel == null):
		if(kids[idx].name == 'Output'):
			panel = kids[idx]
		idx += 1

	if(panel != null):
		panel.make_visible()
