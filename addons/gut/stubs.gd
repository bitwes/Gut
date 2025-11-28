# -------------
# {
# 	object(script or instance):{
# 		method_name1: [StubParams, StubParams],
# 		method_name2: [StubParams, StubParams]
# 	},
# 	object(script or instance):{
# 		method_name1: [StubParams, StubParams],
# 		method_name2: [StubParams, StubParams]
# 	}
# }
var stubs = {}

func _normalize_stub_target(target):
	var to_return = null
	if(typeof(target) == TYPE_OBJECT or GutUtils.is_native_class(target)):
		to_return = target
	if(typeof(target) == TYPE_STRING):
		if(FileAccess.file_exists(target)):
			to_return = load(target)
		else:
			to_return = null
	return to_return


func _get_entries_matching_target(target):
	var match_on = [target]
	var trav = target
	var done = false
	var current = trav

	while(trav != null and !done):
		if(GutUtils.is_singleton_double(trav)):
			trav = trav.__gutdbl.get_singleton()
			match_on.push_front(trav)
		elif(GutUtils.is_instance(trav)):
			trav = trav.get_script()
			match_on.push_front(trav)
		else:
			trav = trav.get_base_script()
			if(trav != null):
				match_on.push_front(trav)
			else:
				var type_name = current.get_instance_base_type()
				trav = GutUtils.class_ref_by_name[type_name]
				match_on.push_front(trav)
				done = true

		if(trav == null):
			done = true
		else:
			current = trav

	return match_on


func clear():
	stubs.clear()


func add_stub(stub_params):
	var key = _normalize_stub_target(stub_params.stub_target)

	if(!stubs.has(key)):
		stubs[key] = {}

	if(!stubs[key].has(stub_params.stub_method)):
		stubs[key][stub_params.stub_method] = []

	stubs[key][stub_params.stub_method].append(stub_params)


func get_all_stubs(thing, method):
	var obj = _normalize_stub_target(thing)
	var match_on = _get_entries_matching_target(obj)

	var matches = []
	for entry in match_on:
		if(stubs.has(entry) and stubs[entry].has(method)):
			matches.append_array(stubs[entry][method])
	return matches


func to_s():
	var text = ''
	for thing in stubs:
		text += str("-- ", thing, " --\n")
		for method in stubs[thing]:
			text += str("\t", method, "\n")
			for i in range(stubs[thing][method].size()):
				text += "\t\t" + stubs[thing][method][i].to_s() + "\n"

	if(text == ''):
		text = 'No Stubs';

	return text
