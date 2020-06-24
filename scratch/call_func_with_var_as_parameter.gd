extends SceneTree

class ParamHandler:
	var _base_parameters = null
	var _call_count = 0

	func is_done():
		return _call_count ==  _base_parameters.size()

	func get_cur_params():
		_call_count += 1
		return _base_parameters[_call_count -1]

	func _init(bp):
		_base_parameters = bp


class FakeTest:
	var  _fg =  null

	func use_parameters(params):
		if(_fg._ph == null):
			_fg._ph = ParamHandler.new(params)
		return _fg._ph.get_cur_params()


class FakeGut:
	var _ph = null
	var _method = null

	func _get_info_for_method(obj, mehtod):
		var list = obj.get_method_list()
		var idx = 0
		var found = false
		while(idx < list.size() and !found):
			if(list[idx]['name'] == mehtod):
				found = true
			else:
				idx += 1

		if(found):
			return list[idx]
		else:
			return null



	func _call_multi(obj, method):
		obj._fg = self
		obj.call(method)
		while(_ph != null and !_ph.is_done()):
			obj.call(method)
		if(_ph == null):
			push_error('You did NOT call use_parameters')
		_ph = null


	func call_method(obj, method):
		var info = _get_info_for_method(obj, method)
		if(info['args'].size() == 0):
			obj.call(method)
		elif(info['args'].size() == 1):
			_call_multi(obj, method)
		else:
			push_error('Too many paramters for ' + method)


class FakeTestScript:
	extends FakeTest

	var changing_value = ['initial']
	var letter_params = [['a', 'b'], ['c', 'd'], ['e', 'f']]

	func some_test(params = use_parameters([1, 2,  3])):
		print(params)

	func use_letters(params = use_parameters(letter_params)):
		print(params)

	func change_the_var(params = use_parameters(changing_value)):
		print(params)
		changing_value = ['changed']

	func use_changed_value(params = use_parameters(changing_value)):
		print(params)

	func causes_error(params = letter_params):
		print(params)

	func test_with_too_many_params(p=1, p2 = 2, p3 =3):
		print(p, p2, p3)

	func test_with_no_params():
		print('no params here')


func _init():
	var fg = FakeGut.new()
	var fts = FakeTestScript.new()

	fg.call_method(fts, 'some_test')
	fg.call_method(fts, 'use_letters')
	fg.call_method(fts, 'change_the_var')
	fg.call_method(fts, 'use_changed_value')
	fg.call_method(fts, 'causes_error')

	fg.call_method(fts, 'test_with_too_many_params')
	fg.call_method(fts, 'test_with_no_params')

	quit()
