extends VBoxContainer
tool

onready var _ctrls = {
	lbl_name = $HBox/Name,
	lbl_status = $HBox/Status,
	hbox = $HBox
}

var _path = null
var _name = null
var _font = null
var _tests = []


func _draw():
	var c = Color(0, 0, .5, .5)
	var r = Rect2(Vector2(0, 0), $HBox.rect_size)
	draw_rect(r, c)
	
	var kids = get_children()
	var odd = false
	for i in range(1, kids.size()):
		if(kids[i].visible):
			if(odd):
				draw_rect(kids[i].get_rect(), Color(0, 0, 0, .2))
			odd = !odd


func set_name(n):
	_name = n
	_ctrls.lbl_name.text = n
	_path = n
	if !_path.ends_with('.gd'):
		var loc = _path.find('.gd')
		_path = _path.substr(0, loc + 3)
		

func update_name_display():
	var total = 0
	var failing = 0
	for test in _tests:
		total += 1
		if(test.get_status() != 'pass'):
			failing += 1
			
	_ctrls.lbl_name.text = str(_name, "      ", failing, '/', total)
	

func set_status(s):
	return
	_ctrls.lbl_status.text = s


func add_test_result(result_obj):
	_tests.append(result_obj)
	var sep = CenterContainer.new()
	sep.rect_min_size.x = 40

	var row = HBoxContainer.new()
#	row.add_child(sep)
	row.add_child(result_obj)
	add_child(row)
	return row
	

func get_path():
	return _path
	
	
func set_font(value, size):
	_font = value.duplicate()
	
	_font.size = size
	_ctrls.lbl_name.add_font_override("font", _font)
