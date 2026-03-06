@tool
extends EditorPlugin

var VersionConversion = load("res://addons/gut/version_conversion.gd")
var MenuManager = load("res://addons/gut/gut_menu.gd")
var BottomPanelScene = preload('res://addons/gut/gui/GutBottomPanel.tscn')
var GutEditorGlobals = load('res://addons/gut/gui/editor_globals.gd')
var GutDock = load('res://addons/gut/gui/gut_dock.gd')
var UpdateRequiredDialog = load('res://addons/gut/gui/update_required.tscn')
var CheckForUpdateControl = load("res://addons/gut/gui/check_for_update.tscn")

var _bottom_panel : Control = null
var _menu_mgr = null
var _gut_button = null
var _gut_window = null
var _dock_mode = 'none'
var _gut_dock = null
var _update_required = null
var _check_for_update = null


func _init():
	if(VersionConversion.error_if_not_all_classes_imported()):
		return


# This checks the Remote file or Local file.  This will not download the
# remote file.  I don't want to delay startup for any reason.  Downloading
# the remote file ocassionally is handled elsewhere.
func _should_continue_loading_gut():
	_check_for_update = CheckForUpdateControl.instantiate()
	var to_return = true

	_update_required = UpdateRequiredDialog.instantiate()
	get_tree().root.add_child(_update_required)
	_update_required.set_check_for_update_control(_check_for_update)

	if(!_check_for_update.update_detector.is_gut_version_valid()):
		_update_required.popup_centered()
		await(_update_required.closed)

		if(!_update_required.should_continue):
			to_return = false

	_update_required.remove_child(_check_for_update)
	_update_required.queue_free()

	return to_return


func _enter_tree():
	if(!_version_conversion()):
		return

	var should_continue = await _should_continue_loading_gut()
	if(!should_continue):
		print("GUT loading canceled.  Restart editor to try loading again.")
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

	# Kick off a download of the remote versions file if it's been more than
	# some number of days since we've downloaded it.
	_check_for_update.visible = false
	_bottom_panel.add_child(_check_for_update)
	var days_since = _check_for_update.update_detector.get_days_since_last_fetch()
	if(days_since >= 1):
		_check_for_update.update_detector.check_for_update_with_fetch(true)

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
	push_warning("You have to right click the GUT tab and choose 'floating'.  I cannot do this from a menu anymore.")


func _exit_tree():
	remove_tool_menu_item("GUT")
	_menu_mgr = null
	GutEditorGlobals.user_prefs.save_it()
	
	if(_bottom_panel != null):
		_bottom_panel.menu_manager = null

	if(_gut_dock != null):
		remove_dock(_gut_dock)
		_gut_dock.queue_free()
	remove_tool_menu_item("GUT") # made by _menu_mgr

	_check_for_update.queue_free()


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
