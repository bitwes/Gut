extends VBoxContainer
tool

var _lbl_name = null
var _lbl_status = null
var _vbox = null
var _path = null
var _name = null
var _tests = []

class Indenter:
	extends CenterContainer
	
	func _draw():
		return
		var re = Rect2(Vector2(0, 0), rect_size)
		draw_rect(re, Color(1, 0, 0), false, 1)
		
		var r = 10
		var c = Vector2(rect_size.x - r, r)
		draw_circle(c, r, Color(1, 1, 1))


func _draw():
	var c = Color(0, 0, .5)
	var r = Rect2(Vector2(0, 0), $HBox.rect_size)
#	draw_rect(r, Color(0, 0, 0, .3))
	draw_rect(r, c)
	
	var kids = get_children()
	var odd = false
	for i in range(1, kids.size()):
		if(kids[i].visible):
			if(odd):
				draw_rect(kids[i].get_rect(), Color(0, 0, 0, .2))
			odd = !odd
			


func _ready():
	_vbox = self
	var hbox = _vbox.get_node("HBox")
	_lbl_name = hbox.get_node("Name")
	_lbl_status = hbox.get_node("Status")

func set_name(n):
	_name = n
	_lbl_name.text = n
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
			
	_lbl_name.text = str(_name, "      ", failing, '/', total)
	


func set_status(s):
	return
	_lbl_status.text = s

func add_test_result(result_obj):
	_tests.append(result_obj)
	var row = HBoxContainer.new()
	var sep = Indenter.new()
	sep.rect_min_size.x = 40

	row.add_child(sep)
	row.add_child(result_obj)
	_vbox.add_child(row)
	
	return row
	

func get_path():
	return _path
