extends Control
tool

onready var _ctrls = {
	lbl_name = $HBox/Name,
	lbl_status = $HBox/Status,
	btn_goto = $HBox/Goto,
	asserts = $Asserts
}

var _path = null
var _line_number = -1

signal goto(path, line_number, method_name)

func _ready():
	_ctrls.btn_goto.connect('pressed', self, '_on_goto_pressed')


func _on_goto_pressed(p=_path, l=_line_number):
	emit_signal("goto", p, l, _ctrls.lbl_name.text)


func _create_assert_row(failure, b_color=Color(1, 1, 1, 1)):
	var f_text = failure
	var line = -1 
	if(failure.find('at line') != -1):
		line = f_text.split("at line")[-1].split(" ")[-1]

	var btn = Button.new()
	btn.text = failure.replace("\n", "")
	btn.size_flags_horizontal = 0
	btn.connect('pressed', self, '_on_goto_pressed', [_path, int(line)])
	btn.align = btn.ALIGN_LEFT
	btn.self_modulate = b_color
	btn.flat = false
	
	var sep = CenterContainer.new()
	sep.rect_min_size.x = 40
	
	var row = HBoxContainer.new()
	row.add_child(sep)
	row.add_child(btn)
	
	_ctrls.asserts.add_child(row)


func set_data(test_name, test_json):
	set_name(test_name)
	var desc = ""
	var line = -1
	
	for failure in test_json.failing:
		_create_assert_row('fail:  ' + failure, Color(1, 0, 0))
	
	for pending in test_json.pending:
		_create_assert_row('pending:  ' + pending, Color(.8, .7, 0))
		
	if(_ctrls.asserts.get_child_count() == 0 and test_json.status != 'pass'):
		_create_assert_row(test_json.status, Color(.8, .7, 0))
		
	set_status(test_json.status, desc)
		

func set_name(value):
	_ctrls.lbl_name.text = value


func set_status(value, text):
	_ctrls.lbl_status.text = text.replace("\n", '')
	_ctrls.lbl_status.visible = false
	
	_ctrls.btn_goto.visible = value != 'pass'
	_ctrls.btn_goto.text = value
	_ctrls.btn_goto.visible = false

	
func get_status():
	return _ctrls.btn_goto.text


func set_goto(path, line_number):
	_path = path
	_line_number = line_number

