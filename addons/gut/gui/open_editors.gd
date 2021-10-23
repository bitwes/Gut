# ------------------------------------------------------------------------------
# Utility for tracking which TextEdit control has focus in the Editor.  Not
# used yet because I had to stop typing and do things outside before yet another
# day disappeared.
# ------------------------------------------------------------------------------
var _script_editor = null
var _num_searched = 0
var _text_edits = []
var _focused = null

signal editor_changed

# Requires reference to the ScriptEditor instance.
func _init(script_edtitor):
	_script_editor = script_edtitor
	_script_editor.connect("editor_script_changed", self, '_on_editor_script_changed')
	_scan_script_editor()


func _on_editor_script_changed(script):
	var old_focus = _focused
	_scan_script_editor()
	if(old_focus != _focused):
		emit_signal('editor_changed')


# Scan through the ScriptEditor finding all TextEdits and populating
# the focused editor.
func _scan_script_editor():
	_focused = _find_focused_editor()

	# if we don't have a reference to the currently selected
	# editor then we need to go look for more editors.
	if(_focused == null):
		_populate_text_edits()
		_focused = _find_focused_editor()


# Searches _text_edits for the editor with focus.  Also prunes stale editor
# refs.  Returns the editor if found, null if not.
func _find_focused_editor():
	var idx = 0
	var focused = null

	while(idx < _text_edits.size() and focused == null):
		if(!_text_edits[idx].get_ref()):
			_text_edits.remove(idx)
		elif(_text_edits[idx].get_ref().has_focus()):
			focused = _text_edits[idx].get_ref()
		else:
			idx += 1

	return focused


# Recursively search through the ScriptEditor for all the TextEdits.  Found
# TextEdits are appended to _text_edits.
func _populate_text_edits(thing=null):
	var ctrl = thing

	if(ctrl == null):
		ctrl = _script_editor
		_num_searched = 0
		_text_edits = []

	var kids = ctrl.get_children()
	var idx = 0
	var found = false
	while(idx < kids.size() and !found):
		if(kids[idx] is TextEdit):
			found = true
			_text_edits.append(weakref(kids[idx]))
		else:
			_num_searched += 1
			_populate_text_edits(kids[idx])
			idx += 1

	if(thing == null):
		print('- searched ', _num_searched)


func get_active_editor():
	return _focused


func print_editors():
	print('----------')
	for edit in _text_edits:
		var s = ' '
		if(edit.get_ref() == _focused):
			s = '*'
		s += str(edit.get_ref())
		print(s)
