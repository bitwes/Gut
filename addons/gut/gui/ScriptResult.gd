extends VBoxContainer
tool

var _lbl_name = null
var _lbl_status = null
var _vbox = null

func _ready():
	_vbox = self
	var hbox = _vbox.get_node("HBox")
	_lbl_name = hbox.get_node("Name")
	_lbl_status = hbox.get_node("Status")

func set_name(n):
	print('setting text ', n)
	_lbl_name.text = n

func set_status(s):
	_lbl_status.text = s

func add_test_result(result_obj):
	var row = HBoxContainer.new()
	var sep = CenterContainer.new()
	sep.rect_min_size.x = 20

	row.add_child(sep)
	row.add_child(result_obj)
	_vbox.add_child(row)
	rect_min_size = _vbox.rect_size

func get_path():
	return _lbl_name.text
