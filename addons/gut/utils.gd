extends Node

static func INSTANCE_NAME():
	return '__GutUtilsInstName__'

static func get_root_node():
	var to_return = null
	var main_loop = Engine.get_main_loop()
	if(main_loop != null):
		return main_loop.root
	else:
		push_error('No Main Loop Yet')
		return null

static func get_instance():
	var the_root = get_root_node()
	var inst = null
	if(the_root.has_node(INSTANCE_NAME())):
		inst = the_root.get_node(INSTANCE_NAME())
	else:
		inst = load('res://addons/gut/utils.gd').new()
		inst.set_name(INSTANCE_NAME())
		the_root.add_child(inst)
	return inst

var Logger = load('res://addons/gut/logger.gd') # everything should use get_logger
var _lgr = null

var _test_mode = false
var AutoFree = load('res://addons/gut/autofree.gd')
var Doubler = load('res://addons/gut/doubler.gd')
var Gut = load('res://addons/gut/gut.gd')
var HookScript = load('res://addons/gut/hook_script.gd')
var MethodMaker = load('res://addons/gut/method_maker.gd')
var OneToMany = load('res://addons/gut/one_to_many.gd')
var OrphanCounter = load('res://addons/gut/orphan_counter.gd')
var ParameterFactory = load('res://addons/gut/parameter_factory.gd')
var ParameterHandler = load('res://addons/gut/parameter_handler.gd')
var Printers = load('res://addons/gut/printers.gd')
var Spy = load('res://addons/gut/spy.gd')
var Strutils = load('res://addons/gut/strutils.gd')
var Stubber = load('res://addons/gut/stubber.gd')
var StubParams = load('res://addons/gut/stub_params.gd')
var Summary = load('res://addons/gut/summary.gd')
var Test = load('res://addons/gut/test.gd')
var TestCollector = load('res://addons/gut/test_collector.gd')
var ThingCounter = load('res://addons/gut/thing_counter.gd')
var version = '6.8.3'

const GUT_METADATA = '__gut_metadata_'

enum DOUBLE_STRATEGY{
	FULL,
	PARTIAL
}

func _init():
	pass
	#print('!!!!!!!!!!!!!! New Utils ', self, ' !!!!!!!!!!!!!!')

var _file_checker = File.new()

func is_version_30():
	var info = Engine.get_version_info()
	return info.major == 3 and info.minor == 0

func is_version_31():
	var info = Engine.get_version_info()
	return info.major == 3 and info.minor == 1

func get_version_text():
	var v_info = Engine.get_version_info()
	var gut_version_info =  str('GUT version:  ', version)
	var godot_version_info  = str('Godot version:  ', v_info.major,  '.',  v_info.minor,  '.',  v_info.patch)
	return godot_version_info + "\n" + gut_version_info

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
# Returns an array created by splitting the string by the delimiter
# ------------------------------------------------------------------------------
func split_string(to_split, delim):
	var to_return = []

	var loc = to_split.find(delim)
	while(loc != -1):
		to_return.append(to_split.substr(0, loc))
		to_split = to_split.substr(loc + 1, to_split.length() - loc)
		loc = to_split.find(delim)
	to_return.append(to_split)
	return to_return

# ------------------------------------------------------------------------------
# Returns a string containing all the elements in the array separated by delim
# ------------------------------------------------------------------------------
func join_array(a, delim):
	var to_return = ''
	for i in range(a.size()):
		to_return += str(a[i])
		if(i != a.size() -1):
			to_return += str(delim)
	return to_return

# ------------------------------------------------------------------------------
# return if_null if value is null otherwise return value
# ------------------------------------------------------------------------------
func nvl(value, if_null):
	if(value == null):
		return if_null
	else:
		return value

# ------------------------------------------------------------------------------
# returns true if the object has been freed, false if not
#
# From what i've read, the weakref approach should work.  It seems to work most
# of the time but sometimes it does not catch it.  The str comparison seems to
# fill in the gaps.  I've not seen any errors after adding that check.
# ------------------------------------------------------------------------------
func is_freed(obj):
	var wr = weakref(obj)
	return !(wr.get_ref() and str(obj) != '[Deleted Object]')

func is_not_freed(obj):
	return !is_freed(obj)

func is_double(obj):
	var to_return = false
	if(typeof(obj) == TYPE_OBJECT):
		to_return = obj.get(GUT_METADATA) != null
	return to_return

func extract_property_from_array(source, property):
	var to_return = []
	for i in (source.size()):
		to_return.append(source[i].get(property))
	return to_return

func file_exists(path):
	return _file_checker.file_exists(path)

func write_file(path, content):
	var f = File.new()
	f.open(path, f.WRITE)
	f.store_string(content)
	f.close()

func is_null_or_empty(text):
	return text == null or text == ''

func get_native_class_name(thing):
	var to_return = null
	if(is_native_class(thing)):
		to_return = thing.new().get_class()
	return to_return

func is_native_class(thing):
	var it_is = false
	if(typeof(thing) == TYPE_OBJECT):
		it_is = str(thing).begins_with("[GDScriptNativeClass:")
	return it_is

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
func get_file_as_text(path):
	var to_return = ''
	var f = File.new()
	var result = f.open(path, f.READ)
	if(result == OK):
		to_return = f.get_as_text()
		f.close()
	return to_return

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
func search_array(ar, prop_method, value):
	var found = false
	var idx = 0

	while(idx < ar.size() and !found):
		var item = ar[idx]
		if(item.get(prop_method) != null):
			if(item.get(prop_method) == value):
				found = true
		elif(item.has_method(prop_method)):
			if(item.call(prop_method) == value):
				found = true

		if(!found):
			idx += 1

	if(found):
		return ar[idx]
	else:
		return null