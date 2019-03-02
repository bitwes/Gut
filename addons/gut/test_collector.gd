# ------------------------------------------------------------------------------
# Used to keep track of info about each test ran.
# ------------------------------------------------------------------------------
class Test:
	# indicator if it passed or not.  defaults to true since it takes only
	# one failure to make it not pass.  _fail in gut will set this.
	var passed = true
	# the name of the function
	var name = ""
	# flag to know if the name has been printed yet.
	var has_printed_name = false
	# the line number the test is on
	var line_number = -1

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
class TestScript:
	var class_name = null
	var tests = []
	var path = null

	func to_s():
		var to_return = path
		if(class_name != null):
			to_return += str('.', class_name)
		to_return += "\n"
		for i in range(tests.size()):
			to_return += str('  ', tests[i].name, "\n")
		return to_return

	func get_new():
		var Script = load(path)
		var inst = null
		if(class_name != null):
			inst = Script.get(class_name).new()
		else:
			inst = Script.new()
		return inst

	func get_full_name():
		var to_return = path
		if(class_name != null):
			to_return += '.' + class_name
		return to_return

	func export_to(config_file, section):
		config_file.set_value(section, 'path', path)
		config_file.set_value(section, 'inner_class', class_name)
		var names = []
		for i in range(tests.size()):
			names.append(tests[i].name)
		config_file.set_value(section, 'tests', names)

	func import_from(config_file, section):
		path = config_file.get_value(section, 'path')
		var test_names = config_file.get_value(section, 'tests')
		for i in range(test_names.size()):
			var t = Test.new()
			t.name = test_names[i]
			tests.append(t)
		# Null is an acceptable value, but you can't pass null as a default to
		# get_value since it thinks you didn't send a default...then it spits
		# out red text.  This works around that.
		var inner_name = config_file.get_value(section, 'inner_class', 'Placeholder')
		if(inner_name != 'Placeholder'):
			class_name = inner_name
		else: # just being explicit
			class_name = null


# ------------------------------------------------------------------------------
# start test_collector, I don't think I like the name.
# ------------------------------------------------------------------------------
var scripts = []
var _test_prefix = 'test_'
var _test_class_prefix = 'Test'

var _utils = load('res://addons/gut/utils.gd').new()
var _lgr = _utils.get_logger()

func _parse_script(script):
	var file = File.new()
	var line = ""
	var line_count = 0
	var inner_classes = []

	file.open(script.path, 1)
	while(!file.eof_reached()):
		line_count += 1
		line = file.get_line()
		#Add a test
		if(line.begins_with("func " + _test_prefix)):
			var from = line.find(_test_prefix)
			var line_len = line.find("(") - from
			var new_test = Test.new()
			new_test.name = line.substr(from, line_len)
			new_test.line_number = line_count
			script.tests.append(new_test)

		if(line.begins_with('class ')):
			var class_name = line.replace('class ', '')
			class_name = class_name.replace(':', '')
			if(class_name.begins_with(_test_class_prefix)):
				inner_classes.append(class_name)

	for i in range(inner_classes.size()):
		var ts = TestScript.new()
		ts.path = script.path
		ts.class_name = inner_classes[i]
		if(_parse_inner_class_tests(ts)):
			scripts.append(ts)

	file.close()

func _parse_inner_class_tests(script):
	var inst = script.get_new()

	if(!inst is load('res://addons/gut/test.gd')):
		_lgr.warn('Ignoring ' + script.class_name + ' because it starts with "' + _test_class_prefix + '" but does not extend addons/gut/test.gd')
		return false

	var methods = inst.get_method_list()
	for i in range(methods.size()):
		var name = methods[i]['name']
		if(name.begins_with(_test_prefix) and methods[i]['flags'] == 65):
			var t = Test.new()
			t.name = name
			script.tests.append(t)

	return true
# -----------------
# Public
# -----------------
func add_script(path):
	# SHORTCIRCUIT
	if(has_script(path)):
		return

	var f = File.new()
	# SHORTCIRCUIT
	if(!f.file_exists(path)):
		_lgr.error('Could not find script:  ' + path)
		return

	var ts = TestScript.new()
	ts.path = path
	scripts.append(ts)
	_parse_script(ts)

func to_s():
	var to_return = ''
	for i in range(scripts.size()):
		to_return += scripts[i].to_s() + "\n"
	return to_return
func get_logger():
	return _lgr

func set_logger(logger):
	_lgr = logger

func get_test_prefix():
	return _test_prefix

func set_test_prefix(test_prefix):
	_test_prefix = test_prefix

func get_test_class_prefix():
	return _test_class_prefix

func set_test_class_prefix(test_class_prefix):
	_test_class_prefix = test_class_prefix

func clear():
	scripts.clear()

func has_script(path):
	var found = false
	var idx = 0
	while(idx < scripts.size() and !found):
		if(scripts[idx].path == path):
			found = true
		else:
			idx += 1
	return found

func export_tests(path):
	var f = ConfigFile.new()
	for i in range(scripts.size()):
		scripts[i].export_to(f, str('TestScript-', i))
	f.save(path)

func import_tests(path):
	var f = ConfigFile.new()
	f.load(path)
	var sections = f.get_sections()
	for key in sections:
		var s = TestScript.new()
		s.import_from(f, key)
		scripts.append(s)
