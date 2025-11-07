
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


# -------------
# returns{} and parameters {} have the following structure
# -------------
# {
# 	inst_id_or_path1:{
# 		method_name1: [StubParams, StubParams],
# 		method_name2: [StubParams, StubParams]
# 	},
# 	inst_id_or_path2:{
# 		method_name1: [StubParams, StubParams],
# 		method_name2: [StubParams, StubParams]
# 	}
# }
# var returns = {}
var parameter_stubs = GutUtils.Stubs.new()
var action_stubs = GutUtils.Stubs.new()

var _lgr = GutUtils.get_logger()
var _strutils = GutUtils.Strutils.new()
var _stub_cache = []


func _init() -> void:
	var _ignore = _class_db_name_hash

# func _find_matches(obj, method):
# 	var matches = []
# 	var last_not_null_parent = null
# 	var singleton_class = null
# 	if(GutUtils.is_double(obj) and obj.__gutdbl_values.from_singleton != ''):
# 		# print(_class_db_name_hash)
# 		var sname = obj.__gutdbl_values.from_singleton
# 		if(_class_db_name_hash.has(sname)):
# 			singleton_class = _class_db_name_hash[sname]
# 		else:
# 			push_error('"', sname, '" could not be found in _class_db_name_hash')
# 			print(_class_db_name_hash)

# 	# Search for what is passed in first.  This could be a class or an instance.
# 	# We want to find the instance before we find the class.  If we do not have
# 	# an entry for the instance then see if we have an entry for the class.
# 	if(returns.has(obj) and returns[obj].has(method)):
# 		matches = returns[obj][method]
# 	elif(singleton_class != null and returns.has(singleton_class) and returns[singleton_class].has(method)):
# 		matches = returns[singleton_class][method]
# 	elif(GutUtils.is_instance(obj)):
# 		var parent = obj.get_script()
# 		var found = false
# 		while(parent != null and !found):
# 			found = returns.has(parent)

# 			if(!found):
# 				last_not_null_parent = parent
# 				parent = parent.get_base_script()

# 		# Could not find the script so check to see if a native class of this
# 		# type was stubbed.
# 		if(!found):
# 			var base_type = last_not_null_parent.get_instance_base_type()
# 			if(_class_db_name_hash.has(base_type)):
# 				parent = _class_db_name_hash[base_type]
# 				found = returns.has(parent)

# 		if(found and returns[parent].has(method)):
# 			matches = returns[parent][method]

# 	return matches


# func _find_matches_for_param_defaults(obj, method):
# 	var matches = []
# 	var last_not_null_parent = null
# 	var singleton_class = null
# 	if(GutUtils.is_double(obj) and obj.__gutdbl_values.from_singleton != ''):
# 		var sname = obj.__gutdbl_values.from_singleton
# 		if(_class_db_name_hash.has(sname)):
# 			singleton_class = _class_db_name_hash[sname]
# 		else:
# 			push_error('"', sname, '" could not be found in _class_db_name_hash')
# 			print(_class_db_name_hash)

# 	# Search for what is passed in first.  This could be a class or an instance.
# 	# We want to find the instance before we find the class.  If we do not have
# 	# an entry for the instance then see if we have an entry for the class.
# 	if(returns.has(obj) and returns[obj].has(method)):
# 		matches.append_array(returns[obj][method])

# 	if(singleton_class != null and returns.has(singleton_class) and returns[singleton_class].has(method)):
# 		matches.append_array(returns[singleton_class][method])

# 	if(GutUtils.is_instance(obj) and singleton_class != null):
# 		var parent = obj.get_script()
# 		var found = false
# 		while(parent != null and !found):
# 			found = returns.has(parent)

# 			if(!found):
# 				last_not_null_parent = parent
# 				parent = parent.get_base_script()

# 		# Could not find the script so check to see if a native class of this
# 		# type was stubbed.
# 		if(!found):
# 			var base_type = last_not_null_parent.get_instance_base_type()
# 			if(_class_db_name_hash.has(base_type)):
# 				parent = _class_db_name_hash[base_type]
# 				found = returns.has(parent)

# 		if(found and returns[parent].has(method)):
# 			matches.append_array(returns[parent][method])

# 	return matches

func _add_cache():
	for stub_params in _stub_cache:
		stub_params.logger = _lgr
		stub_params.stubber = self

		if(stub_params.is_defaults_override()):
			# print("adding prameter default ", stub_params.to_s())
			parameter_stubs.add_stub(stub_params)

		if(!stub_params.is_default_override_only()):
			# print('adding action ', stub_params.to_s())
			action_stubs.add_stub(stub_params)
	_stub_cache.clear()


# Searches returns for an entry that matches the instance or the class that
# passed in obj is.
#
# obj can be an instance, class, or a path.
func _find_stub(obj, method, parameters=null, find_overloads=false):
	_add_cache()
	var to_return = null
	var matches = action_stubs.get_all_stubs(obj, method)

	if(matches.size() == 0):
		return null

	var param_match = null
	var null_match = null
	var overload_match = null

	for i in range(matches.size()):
		var cur_stub = matches[i]

		if(cur_stub.parameters == parameters):
			param_match = cur_stub

		if(cur_stub.parameters == null and !cur_stub.is_default_override_only()):
			null_match = cur_stub

		if(cur_stub.is_defaults_override):
			if(overload_match == null || overload_match.is_script_default):
				overload_match = cur_stub

	if(find_overloads and overload_match != null):
		to_return = overload_match
	# We have matching parameter values so return the stub value for that
	elif(param_match != null):
		to_return = param_match
	# We found a case where the parameters were not specified so return
	# parameters for that.  Only do this if the null match is not *just*
	# a paramerter override stub.
	elif(null_match != null):
		to_return = null_match

	return to_return



# ##############
# Public
# ##############

func add_stub(stub_params):
	if(typeof(stub_params.stub_target) == TYPE_STRING):
		if(!FileAccess.file_exists(stub_params.stub_target)):
			return

	_stub_cache.append(stub_params)
	# stub_params._lgr = _lgr
	# var key = stub_params.stub_target

	# if(!returns.has(key)):
	# 	returns[key] = {}

	# if(!returns[key].has(stub_params.stub_method)):
	# 	returns[key][stub_params.stub_method] = []

	# returns[key][stub_params.stub_method].append(stub_params)


# Gets a stubbed return value for the object and method passed in.  If the
# instance was stubbed it will use that, otherwise it will use the path and
# subpath of the object to try to find a value.
#
# It will also use the optional list of parameter values to find a value.  If
# the object was stubbed with no parameters than any parameters will match.
# If it was stubbed with specific parameter values then it will try to match.
# If the parameters do not match BUT there was also an empty parameter list stub
# then it will return those.
# If it cannot find anything that matches then null is returned.for
#
# Parameters
# obj:  this should be an instance of a doubled object.
# method:  the method called
# parameters:  optional array of parameter vales to find a return value for.
func get_return(obj, method, parameters=null):
	var stub_info = _find_stub(obj, method, parameters)
	print("stub for ", method, ' = ', stub_info)
	if(stub_info != null):
		return stub_info.return_val
	else:
		_lgr.info(str('Call to [', method, '] was not stubbed for the supplied parameters ', parameters, '.  Null was returned.'))
		return null


func should_call_super(obj, method, parameters=null):
	var stub_info = _find_stub(obj, method, parameters)

	var is_partial = false
	if(typeof(obj) != TYPE_STRING): # some stubber tests test with strings
		is_partial = obj.__gutdbl.is_partial
	var should = is_partial

	if(stub_info != null):
		should = stub_info.call_super
	elif(!is_partial):
		# this log message is here because of how the generated doubled scripts
		# are structured.  With this log msg here, you will only see one
		# "unstubbed" info instead of multiple.
		_lgr.info('Unstubbed call to ' + method + '::' + _strutils.type2str(obj))
		should = false

	return should


func get_call_this(obj, method, parameters=null):
	var stub_info = _find_stub(obj, method, parameters)

	if(stub_info != null):
		return stub_info.call_this


func get_default_value(obj, method, p_index):
	_add_cache()
	var the_defaults = []
	var script_defaults = []
	var matches = parameter_stubs.get_all_stubs(obj, method)

	var i = matches.size() -1
	# print('all matches = ', matches)
	while(i >= 0 and the_defaults.is_empty()):
		# print(matches[i].to_s())
		if(matches[i].is_defaults_override()):
			if(matches[i].is_script_default):
				# print(" * script default")
				script_defaults = matches[i].parameter_defaults
			else:
				# print(" * stubbed default")
				the_defaults = matches[i].parameter_defaults
		i -= 1

	if(the_defaults.is_empty() and !script_defaults.is_empty()):
		the_defaults = script_defaults

	var to_return = null
	if(the_defaults.size() > p_index):
		to_return = the_defaults[p_index]
	return to_return


func clear():
	parameter_stubs.clear()
	action_stubs.clear()
	# returns.clear()


func get_logger():
	return _lgr


func set_logger(logger):
	_lgr = logger


func to_s():
	return str("Parameters:\n", parameter_stubs.to_s(),
		"\nActions:\n" , action_stubs.to_s())
	# var text = ''
	# for thing in returns:
	# 	text += str("-- ", thing, " --\n")
	# 	for method in returns[thing]:
	# 		text += str("\t", method, "\n")
	# 		for i in range(returns[thing][method].size()):
	# 			text += "\t\t" + returns[thing][method][i].to_s() + "\n"

	# if(text == ''):
	# 	text = 'Stubber is empty';

	# return text


func stub_defaults_from_meta(target, method_meta):
	var params = GutUtils.StubParams.new(target, method_meta)
	params.is_script_default = true
	add_stub(params)
