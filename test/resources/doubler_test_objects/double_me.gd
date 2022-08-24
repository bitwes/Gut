extends Node
var _value = 0

var should_might_await_await = true

signal signal_signal

func _notification(_what):
	pass

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
	return get_position()

func has_string_and_array_defaults(string_param = "asdf", array_param = [1]):
	pass

func this_just_does_an_await():
	await get_tree().create_timer(1).timeout

func this_is_a_coroutine():
	return await get_tree().create_timer(1).timeout

func calls_coroutine():
	return await this_is_a_coroutine()

func does_something_then_calls_coroutine_then_does_something_else():
	print('This is before the coroutine call')
	await this_is_a_coroutine()
	print('something else')
	return 10

func might_await(should, some_default=3):
	if(should):
		print('awaiting')
		await this_is_a_coroutine()
	else:
		print('not awaiting')

	return

func might_await_no_return(some_default=3):
	if(should_might_await_await):
		print('awaiting')
		await this_is_a_coroutine()
	else:
		print('not awaiting')

func uses_await_response():
	var foo = await this_is_a_coroutine()


func default_is_value(val = _value):
	return val
