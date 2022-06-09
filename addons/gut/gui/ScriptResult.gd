extends VBoxContainer
tool

var _lbl_name = null
var _lbl_status = null
var _vbox = null
var _path = null
var _name = null
var _tests = []

func _draw():
	draw_rect(Rect2(Vector2(0, 0), rect_size), Color(0, 1, 0), false, 2)


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
			
	_lbl_name.text = str(_name, ' ', total - failing, '/', total)


func set_status(s):
	return
	_lbl_status.text = s

func add_test_result(result_obj):
	_tests.append(result_obj)
	var row = HBoxContainer.new()
	var sep = CenterContainer.new()
	sep.rect_min_size.x = 20

	row.add_child(sep)
	row.add_child(result_obj)
	_vbox.add_child(row)
	
	return row
	

func get_path():
	return _path
