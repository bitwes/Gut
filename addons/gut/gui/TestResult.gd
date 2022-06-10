extends Control
tool

var _lbl_name = null
var _lbl_status = null
var _goto_btn = null
var _asserts = null

var _path = null
var _line_number = -1

signal goto(path, line_number, method_name)


class Indenter:
	extends CenterContainer
	
	func _draw():
		var r = Rect2(Vector2(0, 0), rect_size)
		draw_rect(r, Color(1, 0, 0), false, 1)


#func _draw():
#	draw_rect(Rect2(Vector2(0, 0), rect_size), Color(1, 0, 0), false, 1)

func _ready():
	_asserts = $Asserts
	var hbox = get_node("HBox")
	_lbl_name = hbox.get_node("Name")
	_lbl_status = hbox.get_node("Status")
	_goto_btn = hbox.get_node("Goto")

	_goto_btn.connect('pressed', self, '_on_goto_pressed')

func _on_goto_pressed(p=_path, l=_line_number):
	print('**', p, ' ', l)
	emit_signal("goto", p, l, _lbl_name.text)


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
		
		_asserts.add_child(row)


func set_data(test_name, test_json):
	set_name(test_name)
	var desc = ""
	var line = -1
	
	for failure in test_json.failing:
		_create_assert_row('fail:  ' + failure, Color(1, 0, 0))
	
	for pending in test_json.pending:
		_create_assert_row('pending:  ' + pending, Color(.8, .7, 0))
		
	if(_asserts.get_child_count() == 0 and test_json.status != 'pass'):
		_create_assert_row(test_json.status, Color(.8, .7, 0))
		
		
	set_status(test_json.status, desc)
	
#	if(_asserts.get_child_count() == 1):
#		var row = _asserts.get_child(0)
#		row.remove_child(row.get_child(0))
#		_asserts.get_parent().remove_child(_asserts)
#		_lbl_name.get_parent().add_child(_asserts)
	

func set_name(value):
	_lbl_name.text = value

func set_status(value, text):
	_lbl_status.text = text.replace("\n", '')
	_goto_btn.visible = value != 'pass'
	_goto_btn.text = value
	_goto_btn.visible = false
	_lbl_status.visible = false
	
func get_status():
	return _goto_btn.text

func set_goto(path, line_number):
	_path = path
	_line_number = line_number

