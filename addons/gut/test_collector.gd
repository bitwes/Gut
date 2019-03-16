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
	var inner_class_name = null
	var tests = []
	var path = null
	var _utils = null
	var _lgr = null

	func _init(utils=null, logger=null):
		_utils = utils
		_lgr = logger

	func to_s():
		var to_return = path
		if(inner_class_name != null):
			to_return += str('.', inner_class_name)
		to_return += "\n"
		for i in range(tests.size()):
			to_return += str('  ', tests[i].name, "\n")
		return to_return

	func get_new():
		var TheScript = load(path)
		var inst = null
		if(inner_class_name != null):
			inst = TheScript.get(inner_class_name).new()
		else:
			inst = TheScript.new()
		return inst

	func get_full_name():
		var to_return = path
		if(inner_class_name != null):
			to_return += '.' + inner_class_name
		return to_return

	func get_filename():
		return path.get_file()

	func has_inner_class():
		return inner_class_name != null

	func export_to(config_file, section):
		config_file.set_value(section, 'path', path)
		config_file.set_value(section, 'inner_class', inner_class_name)
		var names = []
		for i in range(tests.size()):
			names.append(tests[i].name)
		config_file.set_value(section, 'tests', names)

	func _remap_path(path):
		var to_return = path
		if(!_utils.file_exists(path)):
			_lgr.debug('Checking for remap for:  ' + path)
			var remap_path = path.get_basename() + '.gd.remap'
			if(_utils.file_exists(remap_path)):
				var cf = ConfigFile.new()
				cf.load(remap_path)
				to_return = cf.get_value('remap', 'path')
			else:
				_lgr.warn('Could not find remap file ' + remap_path)
		return to_return

	func import_from(config_file, section):
		path = config_file.get_value(section, 'path')
		path = _remap_path(path)
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
			inner_class_name = inner_name
		else: # just being explicit
			inner_class_name = null


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
	var scripts_found = []

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
			var iclass_name = line.replace('class ', '')
			iclass_name = iclass_name.replace(':', '')
			if(iclass_name.begins_with(_test_class_prefix)):
				inner_classes.append(iclass_name)

	scripts_found.append(script.path)

	for i in range(inner_classes.size()):
		var ts = TestScript.new(_utils, _lgr)
		ts.path = script.path
		ts.inner_class_name = inner_classes[i]
		if(_parse_inner_class_tests(ts)):
			scripts.append(ts)
			scripts_found.append(script.path + '[' + inner_classes[i] +']')

	file.close()
	return scripts_found

func _parse_inner_class_tests(script):
	var inst = script.get_new()

	if(!inst is _utils.Test):
		_lgr.warn('Ignoring ' + script.inner_class_name + ' because it starts with "' + _test_class_prefix + '" but does not extend addons/gut/test.gd')
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
		return []

	var f = File.new()
	# SHORTCIRCUIT
	if(!f.file_exists(path)):
		_lgr.error('Could not find script:  ' + path)
		return

	var ts = TestScript.new(_utils, _lgr)
	ts.path = path
	scripts.append(ts)
	return _parse_script(ts)

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
	if(_utils.is_version_31()):
		_lgr.error("Exporting and importing not supported in 3.1 yet.  There is a workaround, check the wiki.")
		return false
		
	var success = true
	var f = ConfigFile.new()
	for i in range(scripts.size()):
		scripts[i].export_to(f, str('TestScript-', i))
	var result = f.save(path)
	if(result != OK):
		_lgr.error(str('Could not save exported tests to [', path, '].  Error code:  ', result))
		success = false
	return success

func import_tests(path):
	if(_utils.is_version_31()):
		_lgr.error("Exporting and importing not supported in 3.1 yet.  There is a workaround, check the wiki.")
		return false
	var success = false
	var f = ConfigFile.new()
	var result = f.load(path)
	if(result != OK):
		_lgr.error(str('Could not load exported tests from [', path, '].  Error code:  ', result))
	else:
		var sections = f.get_sections()
		for key in sections:
			var ts = TestScript.new(_utils, _lgr)
			ts.import_from(f, key)
			scripts.append(ts)
		success = true
	return success
