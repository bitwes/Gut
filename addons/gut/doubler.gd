# ------------------------------------------------------------------------------
# Utility class to hold the local and built in methods separately.  Add all local
# methods FIRST, then add built ins.
# ------------------------------------------------------------------------------
class ScriptMethods:
	# List of methods that should not be overloaded when they are not defined
	# in the class being doubled.  These either break things if they are
	# overloaded or do not have a "super" equivalent so we can't just pass
	# through.
	var _blacklist = [
		'has_method',
		'get_script',
		'get',
		'_notification',
		'get_path',
		'_enter_tree',
		'_exit_tree',
		'_process',
		'_draw',
		'_physics_process',
		'_input',
		'_unhandled_input',
		'_unhandled_key_input',
		'_set',
		'_get', # probably
		'emit_signal', # can't handle extra parameters to be sent with signal.
	]

	var built_ins = []
	var local_methods = []
	var _method_names = []

	func is_blacklisted(method_meta):
		return _blacklist.find(method_meta.name) != -1

	func _add_name_if_does_not_have(method_name):
		var should_add = _method_names.find(method_name) == -1
		if(should_add):
			_method_names.append(method_name)
		return should_add

	func add_built_in_method(method_meta):
		var did_add = _add_name_if_does_not_have(method_meta.name)
		if(did_add and !is_blacklisted(method_meta)):
			built_ins.append(method_meta)

	func add_local_method(method_meta):
		var did_add = _add_name_if_does_not_have(method_meta.name)
		if(did_add):
			local_methods.append(method_meta)

	func to_s():
		var text = "Locals\n"
		for i in range(local_methods.size()):
			text += str("  ", local_methods[i].name, "\n")
		text += "Built-Ins\n"
		for i in range(built_ins.size()):
			text += str("  ", built_ins[i].name, "\n")
		return text

# ------------------------------------------------------------------------------
# Helper class to deal with objects and inner classes.
# ------------------------------------------------------------------------------
class ObjectInfo:
	var _path = null
	var _subpaths = []
	var _utils = load('res://addons/gut/utils.gd').new()
	var _method_strategy = null
	var make_partial_double = false
	var scene_path = null

	func _init(path, subpath=null):
		_path = path
		if(subpath != null):
			_subpaths = _utils.split_string(subpath, '/')

	# Returns an instance of the class/inner class
	func instantiate():
		return get_loaded_class().new()

	# Can't call it get_class because that is reserved so it gets this ugly name.
	# Loads up the class and then any inner classes to give back a reference to
	# the desired Inner class (if there is any)
	func get_loaded_class():
		var LoadedClass = load(_path)
		for i in range(_subpaths.size()):
			LoadedClass = LoadedClass.get(_subpaths[i])
		return LoadedClass

	func to_s():
		return str(_path, '[', get_subpath(), ']')

	func get_path():
		return _path

	func get_subpath():
		return _utils.join_array(_subpaths, '/')

	func has_subpath():
		return _subpaths.size() != 0

	func get_extends_text():
		var extend = str("extends '", get_path(), '\'')
		if(has_subpath()):
			extend += str('.', get_subpath().replace('/', '.'))
		return extend

	func get_method_strategy():
		return _method_strategy

	func set_method_strategy(method_strategy):
		_method_strategy = method_strategy

# ------------------------------------------------------------------------------
# START Doubler
# ------------------------------------------------------------------------------
var _output_dir = null
var _double_count = 0 # used in making files names unique
var _use_unique_names = true
var _spy = null

var _utils = load('res://addons/gut/utils.gd').new()
var _stubber = _utils.Stubber.new()
var _lgr = _utils.get_logger()
var _method_maker = _utils.MethodMaker.new()
var _strategy = null


func _init(strategy=_utils.DOUBLE_STRATEGY.PARTIAL):
	# make sure _method_maker gets logger too
	set_logger(_utils.get_logger())
	_strategy = strategy

# ###############
# Private
# ###############
func _get_indented_line(indents, text):
	var to_return = ''
	for i in range(indents):
		to_return += "\t"
	return str(to_return, text, "\n")


func _stub_to_call_super(obj_info, method_name):
	var path = obj_info.get_path()
	if(obj_info.scene_path != null):
		path = obj_info.scene_path
	var params = _utils.StubParams.new(path, method_name, obj_info.get_subpath())
	params.to_call_super()
	_stubber.add_stub(params)


func _write_file(obj_info, dest_path, override_path=null):
	var script_methods = _get_methods(obj_info)

	var metadata = _get_stubber_metadata_text(obj_info)
	if(override_path):
		metadata = _get_stubber_metadata_text(obj_info, override_path)

	var f = File.new()
	f.open(dest_path, f.WRITE)

	f.store_string(str(obj_info.get_extends_text(), "\n"))
	f.store_string(metadata)

	for i in range(script_methods.local_methods.size()):
		if(obj_info.make_partial_double):
			_stub_to_call_super(obj_info, script_methods.local_methods[i].name)
		f.store_string(_get_func_text(script_methods.local_methods[i]))

	for i in range(script_methods.built_ins.size()):
		_stub_to_call_super(obj_info, script_methods.built_ins[i].name)
		f.store_string(_get_func_text(script_methods.built_ins[i]))

	f.close()


func _double_scene_and_script(scene_info, dest_path):
	var dir = Directory.new()
	dir.copy(scene_info.get_path(), dest_path)

	var inst = load(scene_info.get_path()).instance()
	var script_path = null
	if(inst.get_script()):
		script_path = inst.get_script().get_path()
	inst.free()

	if(script_path):
		var oi = ObjectInfo.new(script_path)
		oi.set_method_strategy(scene_info.get_method_strategy())
		oi.make_partial_double = scene_info.make_partial_double
		oi.scene_path = scene_info.get_path()
		var double_path = _double(oi, scene_info.get_path())
		var dq = '"'

		var f = File.new()
		f.open(dest_path, f.READ)
		var source = f.get_as_text()
		f.close()

		source = source.replace(dq + script_path + dq, dq + double_path + dq)

		f.open(dest_path, f.WRITE)
		f.store_string(source)
		f.close()

	return script_path

func _get_methods(object_info):
	var obj = object_info.instantiate()
	# any method in the script or super script
	var script_methods = ScriptMethods.new()
	var methods = obj.get_method_list()

	# first pass is for local methods only
	for i in range(methods.size()):
		# 65 is a magic number for methods in script, though documentation
		# says 64.  This picks up local overloads of base class methods too.
		if(methods[i].flags == 65):
			script_methods.add_local_method(methods[i])


	if(object_info.get_method_strategy() == _utils.DOUBLE_STRATEGY.FULL):
		# second pass is for anything not local
		for i in range(methods.size()):
			# 65 is a magic number for methods in script, though documentation
			# says 64.  This picks up local overloads of base class methods too.
			if(methods[i].flags != 65):
				script_methods.add_built_in_method(methods[i])

	return script_methods

func _get_inst_id_ref_str(inst):
	var ref_str = 'null'
	if(inst):
		ref_str = str('instance_from_id(', inst.get_instance_id(),')')
	return ref_str

func _get_stubber_metadata_text(obj_info, override_path = null):
	var path = obj_info.get_path()
	if(override_path != null):
		path = override_path
	return "var __gut_metadata_ = {\n" + \
           "\tpath='" + path + "',\n" + \
		   "\tsubpath='" + obj_info.get_subpath() + "',\n" + \
		   "\tstubber=" + _get_inst_id_ref_str(_stubber) + ",\n" + \
		   "\tspy=" + _get_inst_id_ref_str(_spy) + "\n" + \
           "}\n"

func _get_spy_text(method_hash):
	var txt = ''
	if(_spy):
		var called_with = _method_maker.get_spy_call_parameters_text(method_hash)
		txt += "\t__gut_metadata_.spy.add_call(self, '" + method_hash.name + "', " + called_with + ")\n"
	return txt

func _get_func_text(method_hash):
	var ftxt = _method_maker.get_decleration_text(method_hash) + "\n"

	var called_with = _method_maker.get_spy_call_parameters_text(method_hash)
	ftxt += _get_spy_text(method_hash)

	if(_stubber and method_hash.name != '_init'):
		var call_method = _method_maker.get_super_call_text(method_hash)
		ftxt += "\tif(__gut_metadata_.stubber.should_call_super(self, '" + method_hash.name + "', " + called_with + ")):\n"
		ftxt += "\t\treturn " + call_method + "\n"
		ftxt += "\telse:\n"
		ftxt += "\t\treturn __gut_metadata_.stubber.get_return(self, '" + method_hash.name + "', " + called_with + ")\n"
	else:
		ftxt += "\tpass\n"

	return ftxt

func _get_super_func_text(method_hash):
	var call_method = _method_maker.get_super_call_text(method_hash)

	var call_super_text = str("return ", call_method, "\n")

	var ftxt = _method_maker.get_decleration_text(method_hash) + "\n"
	ftxt += _get_spy_text(method_hash)

	ftxt += _get_indented_line(1, call_super_text)

	return ftxt

# returns the path to write the double file to
func _get_temp_path(object_info):
	var file_name = object_info.get_path().get_file().get_basename()
	var extension = object_info.get_path().get_extension()

	if(object_info.has_subpath()):
		file_name += '__' + object_info.get_subpath().replace('/', '__')

	if(_use_unique_names):
		file_name += str('__dbl', _double_count, '__.', extension)
	else:
		file_name += '.' + extension

	var to_return = _output_dir.plus_file(file_name)
	return to_return

func _double(obj_info, override_path=null):
	var temp_path = _get_temp_path(obj_info)
	_write_file(obj_info, temp_path, override_path)
	_double_count += 1
	return temp_path


func _double_script(path, make_partial, strategy):
	var oi = ObjectInfo.new(path)
	oi.make_partial_double = make_partial
	oi.set_method_strategy(strategy)
	var to_return = load(_double(oi))

	return to_return

func _double_inner(path, subpath, make_partial, strategy):
	var oi = ObjectInfo.new(path, subpath)
	oi.set_method_strategy(strategy)
	oi.make_partial_double = make_partial
	var to_return = load(_double(oi))

	return to_return

func _double_scene(path, make_partial, strategy):
	var oi = ObjectInfo.new(path)
	oi.set_method_strategy(strategy)
	oi.make_partial_double = make_partial
	var temp_path = _get_temp_path(oi)
	_double_scene_and_script(oi, temp_path)

	return load(temp_path)

# ###############
# Public
# ###############
func get_output_dir():
	return _output_dir

func set_output_dir(output_dir):
	_output_dir = output_dir
	var d = Directory.new()
	d.make_dir_recursive(output_dir)

func get_spy():
	return _spy

func set_spy(spy):
	_spy = spy

func get_stubber():
	return _stubber

func set_stubber(stubber):
	_stubber = stubber

func get_logger():
	return _lgr

func set_logger(logger):
	_lgr = logger
	_method_maker.set_logger(logger)

func get_strategy():
	return _strategy

func set_strategy(strategy):
	_strategy = strategy

func partial_double_scene(path, strategy=_strategy):
	return _double_scene(path, true, strategy)

# double a scene
func double_scene(path, strategy=_strategy):
	return _double_scene(path, false, strategy)

# double a script/object
func double(path, strategy=_strategy):
	return _double_script(path, false, strategy)

func partial_double(path, strategy=_strategy):
	return _double_script(path, true, strategy)

func partial_double_inner(path, subpath, strategy=_strategy):
	return _double_inner(path, subpath, true, strategy)

# double an inner class in a script
func double_inner(path, subpath, strategy=_strategy):
	return _double_inner(path, subpath, false, strategy)

func clear_output_directory():
	var did = false
	if(_output_dir.find('user://') == 0):
		var d = Directory.new()
		var result = d.open(_output_dir)
		# BIG GOTCHA HERE.  If it cannot open the dir w/ erro 31, then the
		# directory becomes res:// and things go on normally and gut clears out
		# out res:// which is SUPER BAD.
		if(result == OK):
			d.list_dir_begin(true)
			var f = d.get_next()
			while(f != ''):
				d.remove(f)
				f = d.get_next()
				did = true
	return did

func delete_output_directory():
	var did = clear_output_directory()
	if(did):
		var d = Directory.new()
		d.remove(_output_dir)

# When creating doubles a unique name is used that each double can be its own
# thing.  Sometimes, for testing, we do not want to do this so this allows
# you to turn off creating unique names for each double class.
#
# THIS SHOULD NEVER BE USED OUTSIDE OF INTERNAL GUT TESTING.  It can cause
# weird, hard to track down problems.
func set_use_unique_names(should):
	_use_unique_names = should
