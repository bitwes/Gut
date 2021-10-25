tool
extends WindowDialog

onready var _ctrls = {
	run_all = $Layout/CRunAll/ShortcutButton,
	rerun = $Layout/CRerun/ShortcutButton,
	run_current = $Layout/CRunCurrent/ShortcutButton,
	run_like = $Layout/CRunLike/ShortcutButton,
	run_like_foucs = $Layout/CRunLikeFocus/ShortcutButton,
	panel_button = $Layout/CPanelButton/ShortcutButton,
}


func _ready():
	for key in _ctrls:
		var sc_button = _ctrls[key]
		sc_button.connect('start_edit', self, '_on_edit_start', [sc_button])
		sc_button.connect('end_edit', self, '_on_edit_end')

# ------------
# Events
# ------------
func _on_Hide_pressed():
	hide()

func _on_edit_start(which):
	for key in _ctrls:
		var sc_button = _ctrls[key]
		if(sc_button != which):
			sc_button.disable_set(true)

func _on_edit_end():
	for key in _ctrls:
		var sc_button = _ctrls[key]
		sc_button.disable_set(false)

# ------------
# Public
# ------------
func set_run_all(sc):
	_ctrls.run_all.set_shortcut(sc)

func get_run_all():
	return _ctrls.run_all.get_shortcut()


func set_rerun(sc):
	_ctrls.rerun.set_shortcut(sc)

func get_rerun():
	return _ctrls.rerun.get_shortcut()


func set_run_current(sc):
	_ctrls.run_current.set_shortcut(sc)

func get_run_current():
	return _ctrls.run_current.get_shortcut()


func set_run_like(sc):
	_ctrls.run_like.set_shortcut(sc)

func get_run_like():
	return _ctrls.run_like.get_shortcut()


func set_panel_button(sc):
	_ctrls.panel_button.set_shortcut(sc)


func get_panel_button():
	return _ctrls.panel_button.get_shortcut()


func set_focus_button(sc):
	_ctrls.run_like_foucs.set_shortcut(sc)
	
func get_focus_button():
	return _ctrls.run_like_foucs.get_shortcut()

func save_shortcuts(path):
	var f = ConfigFile.new()
	
	f.set_value('main', 'run_all', _ctrls.run_all.get_shortcut())
	f.set_value('main', 'rerun', _ctrls.rerun.get_shortcut())
	f.set_value('main', 'run_current', _ctrls.run_current.get_shortcut())
	f.set_value('main', 'run_like', _ctrls.run_like.get_shortcut())
	f.set_value('main', 'run_like_focus', _ctrls.run_like_foucs.get_shortcut())
	f.set_value('main', 'panel_button', _ctrls.panel_button.get_shortcut())

	f.save(path)


func load_shortcuts(path):
	var emptyShortcut = ShortCut.new()
	var f = ConfigFile.new()
	f.load(path)
	
	_ctrls.run_all.set_shortcut(f.get_value('main', 'run_all', emptyShortcut))
	_ctrls.rerun.set_shortcut(f.get_value('main', 'rerun', emptyShortcut))
	_ctrls.run_current.set_shortcut(f.get_value('main', 'run_current', emptyShortcut))
	_ctrls.run_like.set_shortcut(f.get_value('main', 'run_like', emptyShortcut))
	_ctrls.run_like_foucs.set_shortcut(f.get_value('main', 'run_like_focus', emptyShortcut))
	_ctrls.panel_button.set_shortcut(f.get_value('main', 'panel_button', emptyShortcut))
