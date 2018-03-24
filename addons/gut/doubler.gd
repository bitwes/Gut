var _output_dir = null
var _stubber = null

# ###############
# Private
# ###############
func _write_file(target_path, dest_path):
	var script_methods = _get_methods(target_path)
	var f = File.new()
	f.open(dest_path, f.WRITE)
	f.store_string(_get_stubber_metadata_text(target_path))
	#f.store_string(str('var mocker = instance_from_id(', get_instance_id(),")\n"))
	#f.store_string(str('var testable = ', testable.dyn_ref(), "\n"))
	for i in range(script_methods.size()):
		f.store_string(_get_func_text(script_methods[i]))
		# var body = str('func ', name, '(', get_arg_text(method_hash['args']), "):\n")
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
	return "var ____gut__metadata = {\n" + \
           "\tpath='" + target_path + "'\n" + \
           "}\n"

func _get_func_text(method_hash):
	var ftxt = str('func ', method_hash['name'], '(')
	ftxt += str(_get_arg_text(method_hash['args']), "):\n")
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
