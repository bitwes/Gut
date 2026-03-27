extends Node

var _value = 0

var should_might_await_await = true

signal signal_signal


func _ready():
	pass

func _init():
	pass

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
	await get_tree().create_timer(1)

func this_is_a_coroutine():
	return await get_tree().create_timer(1)

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

func await_seconds(s):
	await get_tree().create_timer(s).timeout

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


func return_number_plus_one(num : int) -> int :
	return num + 1


func return_string_plus_a(s : String) -> String:
	var new_s : String = str(s, "a")
	return new_s


func void_return()->void:
	pass


func inferred_void_return():
	pass


func inferred_variant_return():
	return


func explicit_int_return() -> int:
	return 7


func inferred_int_return():
	return 8


func two_params_variant_return(p1, p2):
	return