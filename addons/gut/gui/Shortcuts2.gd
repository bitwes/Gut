extends Control



onready var _ctrls = {
	list = $ItemList
}


func _ready():
	_ctrls.list.max_columns = 3
	_ctrls.list.add_item('hello')	
	
	var lbl = Label.new()
	lbl.text = 'world'
