extends Control
tool

var _lbl_name = null
var _lbl_status = null
var _goto_btn = null

var _path = null
var _line_number = -1

signal goto(path, line_number)

func _ready():
	var hbox = get_node("HBox")
	_lbl_name = hbox.get_node("Name")
	_lbl_status = hbox.get_node("Status")
	_goto_btn = hbox.get_node("Goto")

	_goto_btn.connect('pressed', self, '_on_goto_pressed')

func _on_goto_pressed():
	emit_signal("goto", _path, _line_number)

func set_name(value):
	_lbl_name.text = value

func set_status(value):
	_lbl_status.text = value

func set_goto(path, line_number):
	_path = path
	_line_number = line_number

