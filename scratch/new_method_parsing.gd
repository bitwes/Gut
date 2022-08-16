extends SceneTree

class ParsedScript:
	var _methods = []
	var _script_methods = []
	var _method_names = {}

	func _init(thing):
		var methods = thing.get_method_list()
		for m in methods:
			var meth = Method.new(m)
			_methods.append(meth)
			_method_names[m.name] = meth

		methods = thing.get_script_method_list()
		for m in methods:
			var meth = Method.new(m)
			_script_methods.append(meth)
			_method_names[m.name] = meth

	func print_it():
		for m in _methods:
			print(m.to_s())

		for mm in _script_methods:
			print(mm.to_s())

	func get_method(name):
		return _method_names[name]



class Method:
	var _meta = {}
	var _parameters = []
	const NO_DEFAULT = '__no__default__'

	func _init(metadata):
		_meta = metadata
		var start_default = _meta.args.size() - _meta.default_args.size()
		for i in range(_meta.args.size()):
			var arg = _meta.args[i]
			if(i >= start_default):
				arg['default'] = _meta.default_args[start_default - i]
			else:
				arg['default'] = NO_DEFAULT
			_parameters.append(arg)

	func to_s():
		var s = _meta.name + "("
		if(_meta.args.size() != 0):
			s += "\n"

		for arg in _parameters:
			if(str(arg.default) != NO_DEFAULT):
				s += str('  ', arg.name, ' = ', arg.default)
			else:
				s += str('  ', arg.name)
			s += "\n"

		s += ")\n"
		return s




var json = JSON.new()

func pp(dict):
	print(json.stringify(dict, ' '))

func _init():
	var cs = ParsedScript.new(GutTest)
	# cs.print_it()

	var m_assert_eq = cs.get_method('assert_eq')
	print(m_assert_eq.to_s())
	pp(m_assert_eq._meta)

	quit()