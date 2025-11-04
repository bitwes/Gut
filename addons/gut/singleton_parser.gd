class ParsedScript:
	var methods_by_name = {}
	var enums = {}
	var properties = {}
	var signals = {}
	var singleton_name = 'unknown'

	func _init(singleton):
		var sname = singleton.get_class()
		singleton_name = sname

		for method in ClassDB.class_get_method_list(sname, true):
			methods_by_name[method.name] = method

		for e in ClassDB.class_get_enum_list(sname, true):
			for c in ClassDB.class_get_enum_constants(sname, e):
				enums[c] = singleton.get(c)

		for p in ClassDB.class_get_property_list(sname, true):
			properties[p.name] = singleton.get(p.name)

		for s in ClassDB.class_get_signal_list(sname, true):
			signals[s.name] = s

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
var singletons = {}


func parse(singleton):
	var to_return = null
	if(singletons.has(singleton)):
		to_return = singletons[singleton]
	else:
		to_return = ParsedScript.new(singleton)
		singletons[singleton] = to_return

	return to_return