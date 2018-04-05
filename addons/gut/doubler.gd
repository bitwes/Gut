var _output_dir = null
var _stubber = null

# ###############
# Private
# ###############
func _write_file(target_path, dest_path):
	var script_methods = _get_methods(target_path)
	var f = File.new()
	f.open(dest_path, f.WRITE)
	f.store_string(str("extends '", target_path, "'\n"))
	f.store_string(_get_stubber_metadata_text(target_path))
	for i in range(script_methods.size()):
		f.store_string(_get_func_text(script_methods[i]))
	f.close()

func _get_methods(target_path):
	var obj = load(target_path).new()

	var script_methods = [] # any mehtod in the script or super script

	var methods = obj.get_method_list()
	for i in range(methods.size()):
		# 65 is a magic number for methods in script, though documentation
		# says 64.  This picks up local overloads of base class methods too.
		if(methods[i]['flags'] == 65):
			script_methods.append(methods[i])

	return script_methods

func _get_stubber_metadata_text(target_path):
	var stubber_str = 'null'
	if(_stubber):
		stubber_str = str('instance_from_id(', _stubber.get_instance_id(),')')

	return "var __gut_metadata_ = {\n" + \
           "\tpath='" + target_path + "',\n" + \
		   "\tstubber=" + stubber_str + "\n" + \
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

# ###############
# Public
# ###############
func get_output_dir():
	return _output_dir

func set_output_dir(output_dir):
	_output_dir = output_dir
	var d = Directory.new()
	d.make_dir_recursive(output_dir)

func double(obj):
	var temp_path = _output_dir.plus_file(obj.get_file())
	_write_file(obj, temp_path)
	return load(temp_path)

func get_stubber():
	return _stubber

func set_stubber(stubber):
	_stubber = stubber

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
	clear_directory()
	var d = Directory.new()
	d.remove(_output_dir)
