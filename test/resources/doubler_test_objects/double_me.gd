var _value = 0


signal signal_signal

func _ready():
	pass

func _init():
	add_user_signal("user_signal")

func get_value():
	return _value

func set_value(val):
	_value = val

func has_one_param(one):
	pass

func has_two_params_one_default(one, two=null):
	pass

func get_position():
	return super.get_position()

func has_string_and_array_defaults(string_param = "asdf", array_param = [1]):
	pass
