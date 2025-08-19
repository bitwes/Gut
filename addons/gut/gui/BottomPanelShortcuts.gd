@tool
extends Window

var GutEditorGlobals = load('res://addons/gut/gui/editor_globals.gd')
var default_path = GutEditorGlobals.editor_shortcuts_path


@onready var sc_button_run_all = $Layout/CRunAll/ShortcutButton
@onready var sc_button_run_current_script = $Layout/CRunCurrentScript/ShortcutButton
@onready var sc_button_run_current_inner = $Layout/CRunCurrentInner/ShortcutButton
@onready var sc_button_run_current_test = $Layout/CRunCurrentTest/ShortcutButton
@onready var sc_button_run_at_cursor = $Layout/CRunAtCursor/ShortcutButton
@onready var sc_button_rerun = $Layout/CRerun/ShortcutButton
@onready var sc_button_panel = $Layout/CPanelButton/ShortcutButton


@onready var _all_buttons = [
	sc_button_run_all, sc_button_run_current_script, sc_button_run_current_inner,
	sc_button_run_current_test, sc_button_run_at_cursor, sc_button_rerun,
	sc_button_panel
]

func _ready():
	for sc_button in _all_buttons:
		sc_button.connect('start_edit', _on_edit_start.bind(sc_button))
		sc_button.connect('end_edit', _on_edit_end)

	# show dialog when running scene from editor.
	if(get_parent() == get_tree().root):
		popup_centered()


func _cancel_all():
	for sc_button in _all_buttons:
		sc_button.cancel()


# ------------
# Events
# ------------
func _on_Hide_pressed():
	hide()


func _on_edit_start(which):
	for sc_button in _all_buttons:
		if(sc_button != which):
			sc_button.disable_set(true)
			sc_button.disable_clear(true)


func _on_edit_end():
	for sc_button in _all_buttons:
		sc_button.disable_set(false)
		sc_button.disable_clear(false)


func _on_popup_hide():
	_cancel_all()

# ------------
# Public
# ------------


func save_shortcuts():
	save_shortcuts_to_file(default_path)


func save_shortcuts_to_file(path):
	var f = ConfigFile.new()
	f.set_value('main', 'panel_button', sc_button_panel.get_shortcut())
	f.set_value('main', 'rerun', sc_button_rerun.get_shortcut())
	f.set_value('main', 'run_all', sc_button_run_all.get_shortcut())
	f.set_value('main', 'run_at_cursor', sc_button_run_at_cursor.get_shortcut())
	f.set_value('main', 'run_current_inner', sc_button_run_current_inner.get_shortcut())
	f.set_value('main', 'run_current_script', sc_button_run_current_script.get_shortcut())
	f.set_value('main', 'run_current_test', sc_button_run_current_test.get_shortcut())
	f.save(path)


func load_shortcuts():
	load_shortcuts_from_file(default_path)


func load_shortcuts_from_file(path):
	var f = ConfigFile.new()
	# as long as this shortcut is never modified, this is fine, otherwise
	# each thing should get its own default instead.
	var empty = Shortcut.new()

	f.load(path)
	sc_button_panel.set_shortcut(f.get_value('main', 'panel_button', empty))
	sc_button_rerun.set_shortcut(f.get_value('main', 'rerun', empty))
	sc_button_run_all.set_shortcut(f.get_value('main', 'run_all', empty))
	sc_button_run_at_cursor.set_shortcut(f.get_value('main', 'run_at_cursor', empty))
	sc_button_run_current_inner.set_shortcut(f.get_value('main', 'run_current_inner', empty))
	sc_button_run_current_script.set_shortcut(f.get_value('main', 'run_current_script', empty))
	sc_button_run_current_test.set_shortcut(f.get_value('main', 'run_current_test', empty))


# ####
# Saving/Loading to user prefrences has been changed to save/load to a file.
# This is another example of not wanting to throw away code.
# Throw it away when you see fit.
# ####

# var _user_prefs = GutEditorGlobals.user_prefs

# func _set_pref_value(pref, button):
# 	pref.value = {shortcut = button.get_shortcut().events}

# func _load_shortcut_from_pref(user_pref):
# 	var to_return = Shortcut.new()
# 	# value with be _user_prefs.EMPTY which is a string when the value
# 	# has not been set.
# 	if(typeof(user_pref.value) == TYPE_DICTIONARY):
# 		to_return.events.append(user_pref.value.shortcut[0])
# 		# to_return = user_pref.value
# 	return to_return

# func load_shortcuts_from_editor_settings():
# 	sc_button_run_all.set_shortcut(_load_shortcut_from_pref(_user_prefs.shortcut_run_all))
# 	sc_button_run_current_script.set_shortcut(_load_shortcut_from_pref(_user_prefs.shortcut_run_current_script))
# 	sc_button_run_current_inner.set_shortcut(_load_shortcut_from_pref(_user_prefs.shortcut_run_current_inner))
# 	sc_button_run_current_test.set_shortcut(_load_shortcut_from_pref(_user_prefs.shortcut_run_current_test))
# 	sc_button_panel_button.set_shortcut(_load_shortcut_from_pref(_user_prefs.shortcut_panel_button))

# func save_shortcuts_to_editor_settings():
# 	_set_pref_value(_user_prefs.shortcut_run_all, sc_button_run_all)
# 	_set_pref_value(_user_prefs.shortcut_run_current_script, sc_button_run_current_script)
# 	_set_pref_value(_user_prefs.shortcut_run_current_inner, sc_button_run_current_inner)
# 	_set_pref_value(_user_prefs.shortcut_run_current_test, sc_button_run_current_test)
# 	_set_pref_value(_user_prefs.shortcut_panel_button, sc_button_panel_button)

# 	_user_prefs.save_it()
