var _output_dir = null
var _stubber = null
var _double_count = 0
var _use_unique_names = true
var _spy = null

# ###############
# Private
# ###############
func _write_file(target_path, dest_path, override_path=null):
	var script_methods = _get_methods(target_path)

	var metadata = _get_stubber_metadata_text(target_path)
	if(override_path):
		metadata = _get_stubber_metadata_text(override_path)

	var f = File.new()
	f.open(dest_path, f.WRITE)
	f.store_string(str("extends '", target_path, "'\n"))
	f.store_string(metadata)
	for i in range(script_methods.size()):
		f.store_string(_get_func_text(script_methods[i]))
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
	var script_methods = []
	# hold just the names so we can avoid duplicates.
	var method_names = []

	var methods = obj.get_method_list()

	for i in range(methods.size()):
		# 65 is a magic number for methods in script, though documentation
		# says 64.  This picks up local overloads of base class methods too.
		if(methods[i]['flags'] == 65):
			if(!method_names.has(methods[i]['name'])):
				method_names.append(methods[i]['name'])
				script_methods.append(methods[i])

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
	if(method_hash['args'].size() > 0):
		called_with = '['
		for i in range(method_hash['args'].size()):
			called_with += method_hash['args'][i]['name']
			if(i < method_hash['args'].size() - 1):
				called_with += ', '
		called_with += ']'
	return called_with

func _get_func_text(method_hash):
	var ftxt = str('func ', method_hash['name'], '(')
	ftxt += str(_get_arg_text(method_hash['args']), "):\n")

	var called_with = _get_callback_parameters(method_hash)
	if(_spy):
		ftxt += "\t__gut_metadata_.spy.add_call(self, '" + method_hash['name'] + "', " + called_with + ")\n"
	if(_stubber):
		ftxt += "\treturn __gut_metadata_.stubber.get_return(self, '" + method_hash['name'] + "', " + called_with + ")\n"
	else:
		ftxt += "\tpass\n"

	return ftxt

func _get_arg_text(args):
	var text = ''
	for i in range(args.size()):
		text += args[i]['name'] + ' = null'
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

func double(obj):
	return load(_double(obj))

func clear_output_directory():
	var d = Directory.new()
	d.open(_output_dir)
	d.list_dir_begin(true)
	var files = []
	var f = d.get_next()
	while(f != ''):
		d.remove(f)
		f = d.get_next()

func delete_output_directory():
	clear_output_directory()
	var d = Directory.new()
	d.remove(_output_dir)

func set_use_unique_names(should):
	_use_unique_names = should
