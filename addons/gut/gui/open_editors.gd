var _script_editor = null
var _num_searched = 0
var _text_edits = []
var _focused = null


signal editor_changed

func _init(script_edtitor):
    _script_editor = script_edtitor
    _script_editor.connect("editor_script_changed", self, '_on_editor_script_changed')
    _fill_it_up()


func print_editors():
    print('----------')
    for edit in _text_edits:
        var s = ''
        if(edit.get_ref() == _focused):
            s = '*'
        s += str(edit.get_ref())
        print(s)


func _on_editor_script_changed(script):
    var old_focus = _focused
    _fill_it_up()
    if(old_focus != _focused):
        emit_signal('editor_changed')


func _fill_it_up():
    _populate_text_edits()
    _focused = _find_focused_editor()

    if(_focused == null):
        _populate_text_edits()
        _focused = _find_focused_editor()
        print('searched ', _num_searched)


func _find_focused_editor():
    var idx = 0
    var focused = null

    while(idx < _text_edits.size() and focused == null):
        if(!_text_edits[idx].get_ref()):
            _text_edits.remove(idx)
            print('!! removed ', idx)
        elif(_text_edits[idx].get_ref().has_focus()):
            focused = _text_edits[idx].get_ref()
        else:
            idx += 1

    return focused


func _populate_text_edits(thing=null, depth=0):
    var to_return = []
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
            _populate_text_edits(kids[idx], depth + 1)
            idx += 1


func get_active_editor():
    return _focused