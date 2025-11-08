static var _class_db_name_hash = {}

static func _static_init() -> void:
	_class_db_name_hash = _make_crazy_dynamic_over_engineered_class_db_hash()

# So, I couldn't figure out how to get to a reference for a GDNative Class
# using a string.  ClassDB has all thier names...so I made a hash using those
# names and the classes.  Then I dynmaically make a script that has that as
# the source and grab the hash out of it and return it.  Super Rube Golbergery,
# but tons of fun.
static func _make_crazy_dynamic_over_engineered_class_db_hash():
	var text = "var all_the_classes: Dictionary = {\n"
	# These don't actually exist, or can't be referenced in any way.  I could
	# not find anything about them that I could use to exclude them more
	# dynamically.
	var black_list = [
		"GDScriptNativeClass",
		"SceneCacheInterface",
		"SceneRPCInterface",
		"SceneReplicationInterface",
		"ThemeContext",
	]
	for classname in ClassDB.get_class_list():
		if(!black_list.has(classname)):
			text += str('"', classname, '": ', classname, ", \n")

	text += "}"
	var inst =  GutUtils.create_script_from_source(text).new()
	return inst.all_the_classes



var _str = GutUtils.Strutils.new()
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
	var match_on = _get_to_match_on(obj)
	# print('searching for ', obj, '.', method)
	# print("  in ", match_on)

	var matches = []
	for entry in match_on:
		if(stubs.has(entry) and stubs[entry].has(method)):
			matches.append_array(stubs[entry][method])
	return matches


	# var last_not_null_parent = null
	# var singleton_class = null


	# if(GutUtils.is_singleton_double(obj)):
	# 	var sname = obj.__gutdbl_values.from_singleton
	# 	if(_class_db_name_hash.has(sname)):
	# 		singleton_class = _class_db_name_hash[sname]
	# 	else:
	# 		push_error('"', sname, '" could not be found in _class_db_name_hash')
	# 		print(_class_db_name_hash)

	# # Search for what is passed in first.  This could be a class or an instance.
	# # We want to find the instance before we find the class.  If we do not have
	# # an entry for the instance then see if we have an entry for the class.
	# if(stubs.has(obj) and stubs[obj].has(method)):
	# 	matches.append_array(stubs[obj][method])

	# if(singleton_class != null and stubs.has(singleton_class) and stubs[singleton_class].has(method)):
	# 	matches.append_array(stubs[singleton_class][method])

	# if(!GutUtils.is_singleton(obj) and GutUtils.is_instance(obj) and singleton_class == null):
	# 	var parent = obj.get_script()
	# 	var found = false
	# 	print('searching for parent starting at ', parent)
	# 	while(parent != null and !found):
	# 		print('  again ', parent)
	# 		found = stubs.has(parent)

	# 		if(!found):
	# 			last_not_null_parent = parent
	# 			parent = parent.get_base_script()

	# 	# Could not find the script so check to see if a native class of this
	# 	# type was stubbed.
	# 	if(!found):
	# 		var base_type = last_not_null_parent.get_instance_base_type()
	# 		if(_class_db_name_hash.has(base_type)):
	# 			parent = _class_db_name_hash[base_type]
	# 			found = stubs.has(parent)

	# 	if(found and stubs[parent].has(method)):
	# 		matches.append_array(stubs[parent][method])

	# print('matches = ', matches)
	# return matches


func _get_to_match_on(target):
	var match_on = [target]
	var trav = target
	var done = false
	var current = trav

	while(trav != null and !done):
		if(GutUtils.is_singleton_double(trav)):
			# print("singleton double")
			var sname = trav.__gutdbl_values.from_singleton
			# print("sname = ", sname)
			if(_class_db_name_hash.has(sname)):
				trav = _class_db_name_hash[sname]
				# print("pushing ", trav)
				match_on.push_front(trav)
			else:
				# print("don't have it")
				done = true
		elif(GutUtils.is_instance(trav)):
			trav = trav.get_script()
			match_on.push_front(trav)
		else:
			trav = trav.get_base_script()
			if(trav != null):
				match_on.push_front(trav)
			else:
				var type_name = current.get_instance_base_type()
				trav = _class_db_name_hash[type_name]
				match_on.push_front(trav)
				done = true

		if(trav == null):
			done = true
		else:
			# print(current, ' -> ', trav)
			current = trav

	# print("returning ", match_on)
	return match_on


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
