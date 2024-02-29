@tool
class_name GutUtils
extends Object
# ------------------------------------------------------------------------------
# Description
# -----------
# This class is a PSUEDO SINGLETON.  You should not make instances of it but use
# the get_instance static method.
# ------------------------------------------------------------------------------
# NOTE:  I think this can become completely static now that we have static
#		 variables.  A lot would have to change though.  But it would be good
#		 to do.
# ------------------------------------------------------------------------------
const GUT_METADATA = '__gutdbl'


# Note, these cannot change since places are checking for TYPE_INT to determine
# how to process parameters.
enum DOUBLE_STRATEGY{
	INCLUDE_NATIVE,
	SCRIPT_ONLY,
}


enum DIFF {
	DEEP,
	SIMPLE
}

const TEST_STATUSES = {
	NO_ASSERTS = 'no asserts',
	SKIPPED = 'skipped',
	NOT_RUN = 'not run',
	PENDING = 'pending',
	# These two got the "ed" b/c pass is a reserved word and I could not
	# think of better words.
	FAILED = 'fail',
	PASSED = 'pass'
}

static var avail_fonts = ['AnonymousPro', 'CourierPrime', 'LobsterTwo', 'Default']


# This is a holdover from when GUT was making a psuedo autoload.  It would add
# an instance of this class to the tree with a name and retrieve it when
# get_instance was called.  We now have static variables so this var is now
# used instead of a node.
static var _the_instance = null


# ------------------------------------------------------------------------------
# Gets the root node without having to be in the tree and pushing out an error
# if we don't have a main loop ready to go yet.
# ------------------------------------------------------------------------------
static func get_root_node():
	var main_loop = Engine.get_main_loop()
	if(main_loop != null):
		return main_loop.root
	else:
		push_error('No Main Loop Yet')
		return null


# ------------------------------------------------------------------------------
# Get the ONE instance of utils
# ------------------------------------------------------------------------------
static func get_instance():
	if(_the_instance == null):
		_the_instance = GutUtils.new()

	return _the_instance


# ------------------------------------------------------------------------------
# Gets the value from an enum.
# - If passed an integer value as a string it will convert it to an int and
# 	processes the int value.
# - If the value is a float then it is converted to an int and then processes
#	the int value
# - If the value is an int, or was converted to an int, then the enum is checked
#	to see if it contains the value, if so then the value is returned.
#	Otherwise the default is returned.
# - If the value is a string then it is uppercased and all spaces are replaced
#	with underscores.  It then checks to see if enum contains a key of that
#	name.  If so then the value for that key is returned, otherwise the default
#	is returned.
#
# This description is longer than the code, you should have just read the code
# and the tests.
# ------------------------------------------------------------------------------
static func get_enum_value(thing, e, default=null):
	var to_return = default

	if(typeof(thing) == TYPE_STRING and str(thing.to_int()) == thing):
		thing = thing.to_int()
	elif(typeof(thing) == TYPE_FLOAT):
		thing = int(thing)

	if(typeof(thing) == TYPE_STRING):
		var converted = thing.to_upper().replace(' ', '_')
		if(e.keys().has(converted)):
			to_return = e[converted]
	else:
		if(e.values().has(thing)):
			to_return = thing

	return to_return


# ------------------------------------------------------------------------------
# return if_null if value is null otherwise return value
# ------------------------------------------------------------------------------
static func nvl(value, if_null):
	if(value == null):
		return if_null
	else:
		return value


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
static func pretty_print(dict):
	print(JSON.stringify(dict, ' '))


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
static func print_properties(props, thing, print_all_meta=false):
	for i in range(props.size()):
		var prop_name = props[i].name
		var prop_value = thing.get(props[i].name)
		var print_value = str(prop_value)
		if(print_value.length() > 100):
			print_value = print_value.substr(0, 97) + '...'
		elif(print_value == ''):
			print_value = 'EMPTY'

		print(prop_name, ' = ', print_value)
		if(print_all_meta):
			print('  ', props[i])



# ------------------------------------------------------------------------------
# Gets the value of the node_property 'script' from a PackedScene's root node.
# This does not assume the location of the root node in the PackedScene's node
# list.  This also does not assume the index of the 'script' node property in
# a nodes's property list.
# ------------------------------------------------------------------------------
static func get_scene_script_object(scene):
	var state = scene.get_state()
	var to_return = null
	var root_node_path = NodePath(".")
	var node_idx = 0

	while(node_idx < state.get_node_count() and to_return == null):
		if(state.get_node_path(node_idx) == root_node_path):
			for i in range(state.get_node_property_count(node_idx)):
				if(state.get_node_property_name(node_idx, i) == 'script'):
					to_return = state.get_node_property_value(node_idx, i)

		node_idx += 1

	return to_return


# ##############################################################################
# Start Class
# ##############################################################################
var Logger = load('res://addons/gut/logger.gd') # everything should use get_logger
var _lgr = null
var json = JSON.new()

var _test_mode = false

var AutoFree = load('res://addons/gut/autofree.gd')
var Awaiter = load('res://addons/gut/awaiter.gd')
var Comparator = load('res://addons/gut/comparator.gd')
var CompareResult = load('res://addons/gut/compare_result.gd')
var DiffTool = load('res://addons/gut/diff_tool.gd')
var Doubler = load('res://addons/gut/doubler.gd')
var Gut = load('res://addons/gut/gut.gd')
var GutConfig = load('res://addons/gut/gut_config.gd')
var HookScript = load('res://addons/gut/hook_script.gd')
var InnerClassRegistry = load('res://addons/gut/inner_class_registry.gd')
var InputFactory = load("res://addons/gut/input_factory.gd")
var InputSender = load("res://addons/gut/input_sender.gd")
var JunitXmlExport = load('res://addons/gut/junit_xml_export.gd')
var MethodMaker = load('res://addons/gut/method_maker.gd')
var OneToMany = load('res://addons/gut/one_to_many.gd')
var OrphanCounter = load('res://addons/gut/orphan_counter.gd')
var ParameterFactory = load('res://addons/gut/parameter_factory.gd')
var ParameterHandler = load('res://addons/gut/parameter_handler.gd')
var Printers = load('res://addons/gut/printers.gd')
var ResultExporter = load('res://addons/gut/result_exporter.gd')
var ScriptCollector = load('res://addons/gut/script_parser.gd')
var Spy = load('res://addons/gut/spy.gd')
var Strutils = load('res://addons/gut/strutils.gd')
var Stubber = load('res://addons/gut/stubber.gd')
var StubParams = load('res://addons/gut/stub_params.gd')
var Summary = load('res://addons/gut/summary.gd')
var Test = load('res://addons/gut/test.gd')
var TestCollector = load('res://addons/gut/test_collector.gd')
var ThingCounter = load('res://addons/gut/thing_counter.gd')
var CollectedTest = load('res://addons/gut/collected_test.gd')
var CollectedScript = load('res://addons/gut/collected_test.gd')

var GutScene = load('res://addons/gut/GutScene.tscn')

# Source of truth for the GUT version
var version = '9.2.1'
# The required Godot version as an array.
var req_godot = [4, 2, 0]


# ------------------------------------------------------------------------------
# Blurb of text with GUT and Godot versions.
# ------------------------------------------------------------------------------
func get_version_text():
	var v_info = Engine.get_version_info()
	var gut_version_info =  str('GUT version:  ', version)
	var godot_version_info  = str('Godot version:  ', v_info.major,  '.',  v_info.minor,  '.',  v_info.patch)
	return godot_version_info + "\n" + gut_version_info


# ------------------------------------------------------------------------------
# Returns a nice string for erroring out when we have a bad Godot version.
# ------------------------------------------------------------------------------
func get_bad_version_text():
	var ver = '.'.join(PackedStringArray(req_godot))
	var info = Engine.get_version_info()
	var gd_version = str(info.major, '.', info.minor, '.', info.patch)
	return 'GUT ' + version + ' requires Godot ' + ver + ' or greater.  Godot version is ' + gd_version


# ------------------------------------------------------------------------------
# Checks the Godot version against req_godot array.
# ------------------------------------------------------------------------------
func is_version_ok(engine_info=Engine.get_version_info(),required=req_godot):
	var is_ok = null
	var engine_array = [engine_info.major, engine_info.minor, engine_info.patch]

	var idx = 0
	while(is_ok == null and idx < engine_array.size()):
		if(engine_array[idx] > required[idx]):
			is_ok = true
		elif(engine_array[idx] < required[idx]):
			is_ok = false

		idx += 1

	# still null means each index was the same.
	return nvl(is_ok, true)


func godot_version(engine_info=Engine.get_version_info()):
	return str(engine_info.major, '.', engine_info.minor, '.', engine_info.patch)


func is_godot_version(expected, engine_info=Engine.get_version_info()):
	var engine_array = [engine_info.major, engine_info.minor, engine_info.patch]
	var expected_array = expected.split('.')

	if(expected_array.size() > engine_array.size()):
		return false

	var is_version = true
	var i = 0
	while(i < expected_array.size() and i < engine_array.size() and is_version):
		if(expected_array[i] == str(engine_array[i])):
			i += 1
		else:
			is_version = false

	return is_version


func is_godot_version_gte(expected, engine_info=Engine.get_version_info()):
	return is_version_ok(engine_info, expected.split('.'))


# ------------------------------------------------------------------------------
# Everything should get a logger through this.
#
# When running in test mode this will always return a new logger so that errors
# are not caused by getting bad warn/error/etc counts.
# ------------------------------------------------------------------------------
func get_logger():
	if(_test_mode):
		return Logger.new()
	else:
		if(_lgr == null):
			_lgr = Logger.new()
		return _lgr


# ------------------------------------------------------------------------------
# returns true if the object has been freed, false if not
#
# From what i've read, the weakref approach should work.  It seems to work most
# of the time but sometimes it does not catch it.  The str comparison seems to
# fill in the gaps.  I've not seen any errors after adding that check.
# ------------------------------------------------------------------------------
func is_freed(obj):
	var wr = weakref(obj)
	return !(wr.get_ref() and str(obj) != '<Freed Object>')


# ------------------------------------------------------------------------------
# Pretty self explanitory.
# ------------------------------------------------------------------------------
func is_not_freed(obj):
	return !is_freed(obj)


# ------------------------------------------------------------------------------
# Checks if the passed in object is a GUT Double or Partial Double.
# ------------------------------------------------------------------------------
func is_double(obj):
	var to_return = false
	if(typeof(obj) == TYPE_OBJECT and is_instance_valid(obj)):
		to_return = obj.has_method('__gutdbl_check_method__')
	return to_return


# ------------------------------------------------------------------------------
# Checks if the passed in is an instance of a class
# ------------------------------------------------------------------------------
func is_instance(obj):
	return typeof(obj) == TYPE_OBJECT and !is_native_class(obj) and !obj.has_method('new') and !obj.has_method('instantiate')

# ------------------------------------------------------------------------------
# Checks if the passed in is a GDScript
# ------------------------------------------------------------------------------
func is_gdscript(obj):
	return typeof(obj) == TYPE_OBJECT and str(obj).begins_with('<GDScript#')


# ------------------------------------------------------------------------------
# Checks if the passed in is an inner class
#
# Looks like the resource_path will be populated for gdscripts, and not populated
# for gdscripts inside a gdscript.
# ------------------------------------------------------------------------------
func is_inner_class(obj):
	return is_gdscript(obj) and obj.resource_path == ''


# ------------------------------------------------------------------------------
# Returns an array of values by calling get(property) on each element in source
# ------------------------------------------------------------------------------
func extract_property_from_array(source, property):
	var to_return = []
	for i in (source.size()):
		to_return.append(source[i].get(property))
	return to_return


# ------------------------------------------------------------------------------
# true if file exists, false if not.
# ------------------------------------------------------------------------------
func file_exists(path):
	return FileAccess.file_exists(path)


# ------------------------------------------------------------------------------
# Write a file.
# ------------------------------------------------------------------------------
func write_file(path, content):
	var f = FileAccess.open(path, FileAccess.WRITE)
	if(f != null):
		f.store_string(content)
	f = null;

	return FileAccess.get_open_error()

# ------------------------------------------------------------------------------
# true if what is passed in is null or an empty string.
# ------------------------------------------------------------------------------
func is_null_or_empty(text):
	return text == null or text == ''


# ------------------------------------------------------------------------------
# Get the name of a native class or null if the object passed in is not a
# native class.
# ------------------------------------------------------------------------------
func get_native_class_name(thing):
	var to_return = null
	if(is_native_class(thing)):
		var newone = thing.new()
		to_return = newone.get_class()
		if(!newone is RefCounted):
			newone.free()
	return to_return


# ------------------------------------------------------------------------------
# Checks an object to see if it is a GDScriptNativeClass
# ------------------------------------------------------------------------------
func is_native_class(thing):
	var it_is = false
	if(typeof(thing) == TYPE_OBJECT):
		it_is = str(thing).begins_with("<GDScriptNativeClass#")
	return it_is


# ------------------------------------------------------------------------------
# Returns the text of a file or an empty string if the file could not be opened.
# ------------------------------------------------------------------------------
func get_file_as_text(path):
	var to_return = ''
	var f = FileAccess.open(path, FileAccess.READ)
	if(f != null):
		to_return = f.get_as_text()
	f = null
	return to_return

# ------------------------------------------------------------------------------
# Loops through an array of things and calls a method or checks a property on
# each element until it finds the returned value.  -1 is returned if not found
# or the index is returned if found.
# ------------------------------------------------------------------------------
func search_array_idx(ar, prop_method, value):
	var found = false
	var idx = 0

	while(idx < ar.size() and !found):
		var item = ar[idx]
		var prop = item.get(prop_method)
		if(!(prop is Callable)):
			if(item.get(prop_method) == value):
				found = true
		elif(prop != null):
			var called_val = prop.call()
			if(called_val == value):
				found = true

		if(!found):
			idx += 1

	if(found):
		return idx
	else:
		return -1

# ------------------------------------------------------------------------------
# Loops through an array of things and calls a method or checks a property on
# each element until it finds the returned value.  The item in the array is
# returned or null if it is not found (this method originally came first).
# ------------------------------------------------------------------------------
func search_array(ar, prop_method, value):
	var idx = search_array_idx(ar, prop_method, value)

	if(idx != -1):
		return ar[idx]
	else:
		return null


func are_datatypes_same(got, expected):
	return !(typeof(got) != typeof(expected) and got != null and expected != null)


func get_script_text(obj):
	return obj.get_script().get_source_code()


func get_singleton_by_name(name):
	var source = str("var singleton = ", name)
	var script = GDScript.new()
	script.set_source_code(source)
	script.reload()
	return script.new().singleton


func dec2bistr(decimal_value, max_bits = 31):
	var binary_string = ""
	var temp
	var count = max_bits

	while(count >= 0):
		temp = decimal_value >> count
		if(temp & 1):
			binary_string = binary_string + "1"
		else:
			binary_string = binary_string + "0"
		count -= 1

	return binary_string


func add_line_numbers(contents):
	if(contents == null):
		return ''

	var to_return = ""
	var lines = contents.split("\n")
	var line_num = 1
	for line in lines:
		var line_str = str(line_num).lpad(6, ' ')
		to_return += str(line_str, ' |', line, "\n")
		line_num += 1
	return to_return

func pp(dict, indent=''):
	var text = json.stringify(dict, '  ')
	print(text)


var _created_script_count = 0
func create_script_from_source(source, override_path=null):
	_created_script_count += 1
	var r_path = str('gut_dynamic_script_', _created_script_count)
	if(override_path != null):
		r_path = override_path

	var DynamicScript = GDScript.new()
	DynamicScript.source_code = source
	# The resource_path must be unique or Godot thinks it is trying
	# to load something it has already loaded and generates an error like
	# ERROR: Another resource is loaded from path 'workaround for godot issue #65263' (possible cyclic resource inclusion).
	DynamicScript.resource_path = r_path
	var result = DynamicScript.reload()

	return DynamicScript


func get_display_size():
	return Engine.get_main_loop().get_viewport().get_visible_rect()



# ##############################################################################
#(G)odot (U)nit (T)est class
#
# ##############################################################################
# The MIT License (MIT)
# =====================
#
# Copyright (c) 2023 Tom "Butch" Wesley
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# ##############################################################################

