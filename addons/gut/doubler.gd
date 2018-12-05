var _output_dir = null
var _stubber = null
var _double_count = 0
var _use_unique_names = true
var _spy = null
const PARAM_PREFIX = 'p_'
const NAME = 'name'
const ARGS = 'args'
const FLAGS = 'flags'


# Utility class to hold the local and built in methods seperately.  Add all local
# methods FIRST, then add built ins.
class ScriptMethods:

	var _blacklist = [
		# # from Object
		# 'add_user_signal',
		# 'has_user_signal',
		# 'emit_signal',
		# 'get_signal_connection_list',
		# 'connect',
		# 'disconnect',
		# 'is_connected',
		#
		# # from Node2D
		# 'draw_char',
		#
		# # found during other testing.
		# 'call',
		# '_ready',

		'has_method',
		'get_script',
		'get',
		'_notification',
		'get_path',
		'_enter_tree',
		'_exit_tree',
	]

	var built_ins = []
	var local_methods = []
	var _method_names = []
	const NAME = 'name'

	func _add_name_if_does_not_have(method_name):
		var has = _method_names.find(method_name) != -1
		if(!has):
			_method_names.append(method_name)
		return has

	func add_built_in_method(method_meta):
		var has = _add_name_if_does_not_have(method_meta[NAME])
		if(!has and _blacklist.find(method_meta[NAME]) == -1):
			built_ins.append(method_meta)

	func add_local_method(method_meta):
		# add to the list of names so that when we add built-ins we do not get
		# duplicates.
		_add_name_if_does_not_have(method_meta[NAME])
		# do not check if we have it, because we shouldn't if we add the locals
		# first.  We only check builts-ins b/c they can appear in multiple lists
		# but there shouldn't be any locals that have beend duplciated (again,
		# if we add all the locals first)
		local_methods.append(method_meta)

	func to_s():
		var text = "Locals\n"
		for i in range(local_methods.size()):
			text += str("  ", local_methods[i][NAME], "\n")
		text += "Built-Ins\n"
		for i in range(built_ins.size()):
			text += str("  ", built_ins[i][NAME], "\n")
		return text

# ###############
# Private
# ###############

func _get_indented_line(indents, text):
	var to_return = ''
	for i in range(indents):
		to_return += "\t"
	return str(to_return, text, "\n")

func _write_file(target_path, dest_path, override_path=null):
	var script_methods = _get_methods(target_path)

	var metadata = _get_stubber_metadata_text(target_path)
	if(override_path):
		metadata = _get_stubber_metadata_text(override_path)

	var f = File.new()
	f.open(dest_path, f.WRITE)
	f.store_string(str("extends '", target_path, "'\n"))
	f.store_string(metadata)
	for i in range(script_methods.local_methods.size()):
		f.store_string(_get_func_text(script_methods.local_methods[i]))
	for i in range(script_methods.built_ins.size()):
		f.store_string(_get_super_func_text(script_methods.built_ins[i]))
	f.close()

func _double_scene_and_script(target_path, dest_path):
	var dir = Directory.new()
	dir.copy(target_path, dest_path)

	var inst = load(target_path).instance()
	var script_path = null
	if(inst.get_script()):
		script_path = inst.get_script().get_path()
	inst.free()

	if(script_path):
		var double_path = _double(script_path, target_path)
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

func _get_methods(target_path):
	var obj = load(target_path).new()
	# any mehtod in the script or super script
	var script_methods = ScriptMethods.new()
	var methods = obj.get_method_list()

	# first pass is for local mehtods only
	for i in range(methods.size()):
		# 65 is a magic number for methods in script, though documentation
		# says 64.  This picks up local overloads of base class methods too.
		if(methods[i][FLAGS] == 65):
			script_methods.add_local_method(methods[i])

	# second pass is for anything not local
	for i in range(methods.size()):
		# 65 is a magic number for methods in script, though documentation
		# says 64.  This picks up local overloads of base class methods too.
		if(methods[i][FLAGS] != 65):
			script_methods.add_built_in_method(methods[i])

	return script_methods

func _get_inst_id_ref_str(inst):
	var ref_str = 'null'
	if(inst):
		ref_str = str('instance_from_id(', inst.get_instance_id(),')')
	return ref_str

func _get_stubber_metadata_text(target_path):
	return "var __gut_metadata_ = {\n" + \
           "\tpath='" + target_path + "',\n" + \
		   "\tstubber=" + _get_inst_id_ref_str(_stubber) + ",\n" + \
		   "\tspy=" + _get_inst_id_ref_str(_spy) + "\n" + \
           "}\n"

func _get_callback_parameters(method_hash):
	var called_with = 'null'
	if(method_hash[ARGS].size() > 0):
		called_with = '['
		for i in range(method_hash[ARGS].size()):
			called_with += method_hash[ARGS][i][NAME]
			if(i < method_hash[ARGS].size() - 1):
				called_with += ', '
		called_with += ']'
	return called_with

func _get_func_text(method_hash):
	var ftxt = str('func ', method_hash[NAME], '(')
	ftxt += str(_get_arg_text(method_hash[ARGS]), "):\n")

	var called_with = _get_callback_parameters(method_hash)
	if(_spy):
		ftxt += "\t__gut_metadata_.spy.add_call(self, '" + method_hash[NAME] + "', " + called_with + ")\n"
	if(_stubber):
		ftxt += "\treturn __gut_metadata_.stubber.get_return(self, '" + method_hash[NAME] + "', " + called_with + ")\n"
	else:
		ftxt += "\tpass\n"

	return ftxt

func _get_super_call_parameters(method_hash):
	var params = ''
	for i in range(method_hash[ARGS].size()):
		params += PARAM_PREFIX + method_hash[ARGS][i][NAME]
		if(method_hash[ARGS].size() > 1 and i != method_hash[ARGS].size() -1):
			params += ', '
	return params

func _get_super_func_text(method_hash):
	var call_super_text = str(
		"return .",
		method_hash[NAME],
		"(",
		_get_super_call_parameters(method_hash),
		")\n")
	var ftxt = str('func ', method_hash[NAME], '(')
	ftxt += str(_get_arg_text(method_hash[ARGS]), "):\n")
	ftxt += _get_indented_line(1, call_super_text)

	return ftxt

func _get_arg_text(args):
	var text = ''
	for i in range(args.size()):
		text += PARAM_PREFIX + args[i][NAME] + ' = null'
		if(i != args.size() -1):
			text += ', '
	return text

func _get_temp_path(path):
	var file_name = path.get_file()
	if(_use_unique_names):
		file_name = file_name.get_basename() + \
		            str('__dbl', _double_count, '__.') + file_name.get_extension()
	var to_return = _output_dir.plus_file(file_name)
	return to_return

func _double(obj, override_path=null):
	var temp_path = _get_temp_path(obj)
	_write_file(obj, temp_path, override_path)
	_double_count += 1
	return temp_path

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

func double_scene(path):
	var temp_path = _get_temp_path(path)
	_double_scene_and_script(path, temp_path)
	return load(temp_path)

func double(path):
	return load(_double(path))

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
			var files = []
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

func set_use_unique_names(should):
	_use_unique_names = should
