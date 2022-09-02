# ##############################################################################
#(G)odot (U)nit (T)est class
#
# ##############################################################################
# The MIT License (MIT)
# =====================
#
# Copyright (c) 2020 Tom "Butch" Wesley
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
# Description
# -----------
# ##############################################################################

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
		'draw_mesh', # issue with one parameter, value is `Null((..), (..), (..))``
		'_to_string', # nonexistant function super._to_string
		'_get_minimum_size', # Nonexistent function _get_minimum_size
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
	var _utils = load('res://addons/gut/utils.gd').get_instance()
	var _lgr = _utils.get_logger()
	var _method_strategy = null
	var make_partial_double = false
	var scene_path = null
	var _native_class = null
	var _native_class_name = null
	var _singleton_instance = null
	var _singleton_name = null

	func _init(path,subpath=null):
		_path = path
		if(subpath != null):
			_subpaths = Array(subpath.split('/'))

	# Returns an instantiate of the class/inner class
	func instantiate():
		var to_return = null

		if(_singleton_instance != null):
			to_return = _singleton_instance
		elif(is_native()):
			to_return = _native_class.new()
		else:
			to_return = get_loaded_class().new()

		return to_return


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
		return '/'.join(PackedStringArray(_subpaths))


	func has_subpath():
		return _subpaths.size() != 0


	func get_method_strategy():
		return _method_strategy


	func set_method_strategy(method_strategy):
		_method_strategy = method_strategy


	func is_native():
		return _native_class != null


	func set_native_class(native_class):
		_native_class = native_class
		var inst = native_class.new()
		_native_class_name = inst.get_class()
		_path = _native_class_name
		if(!inst is RefCounted):
			inst.free()


	func get_native_class_name():
		return _native_class_name


	func get_singleton_instance():
		return _singleton_instance


	func get_singleton_name():
		return _singleton_name


	func set_singleton_name(singleton_name):
		_singleton_name = singleton_name
		_singleton_instance = _utils.get_singleton_by_name(_singleton_name)


	func is_singleton():
		return _singleton_instance != null


	func get_extends_text():
		var extend = null
		if(is_singleton()):
			extend = str("# Double of singleton ", _singleton_name, ", base class is RefCounted")
		elif(is_native()):
			var native = get_native_class_name()
			if(native.begins_with('_')):
				native = native.substr(1)
			extend = str("extends ", native)
		else:
			extend = str("extends '", get_path(), "'")

		if(has_subpath()):
			extend += str('.', get_subpath().replace('/', '.'))

		return extend


	func get_constants_text():
		if(!is_singleton()):
			return ""

		# do not include constants defined in the super class which for
		# singletons stubs is RefCounted.
		var exclude_constants = Array(ClassDB.class_get_integer_constant_list("RefCounted"))
		var text = str("# -----\n# ", _singleton_name, " Constants\n# -----\n")
		var constants = ClassDB.class_get_integer_constant_list(_singleton_name)
		for c in constants:
			if(!exclude_constants.has(c)):
				var value = ClassDB.class_get_integer_constant(_singleton_name, c)
				text += str("const ", c, " = ", value, "\n")

		return text

	func get_properties_text():
		if(!is_singleton()):
			return ""

		var text = str("# -----\n# ", _singleton_name, " Properties\n# -----\n")
		var props = ClassDB.class_get_property_list(_singleton_name)
		for prop in props:
			var accessors = {"setter":null, "getter":null}
			var prop_text = str("var ", prop["name"])

			var getter_name = "get_" + prop["name"]
			if(ClassDB.class_has_method(_singleton_name, getter_name)):
				accessors.getter = getter_name
			else:
				getter_name = "is_" + prop["name"]
				if(ClassDB.class_has_method(_singleton_name, getter_name)):
					accessors.getter = getter_name

			var setter_name = "set_" + prop["name"]
			if(ClassDB.class_has_method(_singleton_name, setter_name)):
				accessors.setter = setter_name

			var setget_text = ""
			if(accessors.setter != null and accessors.getter != null):
				setget_text = str("setget ", accessors.setter, ", ", accessors.getter)
			else:
				# never seen this message show up, but it should show up if we
				# get misbehaving singleton.
				_lgr.error(str("Could not find setget methods for property:  ",
					_singleton_name, ".",  prop["name"]))

			text += str(prop_text, " ", setget_text, "\n")

		return text


# ------------------------------------------------------------------------------
# This is what is left of stripping out the old "write a file" method of
# creating doubles.  It's now just a string with the load_it function.
# It seemed like there could be some utility in maintaining this little
# class.
# ------------------------------------------------------------------------------
class DoubledScript:
	extends File

	var _contents  = ''

	func append(s):
		_contents += s

	func get_contents():
		return _contents

	func load_it():
		if(_contents != ''):
			var script = GDScript.new()
			script.source_code = _contents
			# this is causing an error in 4.0 (print only)
			# ERROR: Attempt to open script '' resulted in error 'File not found'.
			# Everyting seems to work.  I suspect that the path is empty and it
			# is throwing an erro that should not be thrown.
			var result = script.reload()
			return script


# ------------------------------------------------------------------------------
# A stroke of genius if I do say so.  This allows for doubling a scene without
# having  to write any files.  By overloading the "instantiate" method  we can
# make whatever we want.
# ------------------------------------------------------------------------------
class PackedSceneDouble:
	extends PackedScene
	var _script =  null
	var _scene = null

	func set_script_obj(obj):
		_script = obj

	func instantiate(edit_state=0):
		var inst = _scene.instantiate(edit_state)
		if(_script !=  null):
			inst.set_script(_script)
		return inst

	func load_scene(path):
		_scene = load(path)




# ------------------------------------------------------------------------------
# START Doubler
# ------------------------------------------------------------------------------
var _utils = load('res://addons/gut/utils.gd').get_instance()
var _double_count = 0 # used in making files names unique
var _base_script_text = _utils.get_file_as_text('res://addons/gut/double_templates/script_template.txt')
var _make_files = false
# used by tests for debugging purposes.
var _print_source = false


# ###############
# Properties
# ###############
var _stubber = _utils.Stubber.new()
func get_stubber():
	return _stubber
func set_stubber(stubber):
	_stubber = stubber

var _lgr = _utils.get_logger()
func get_logger():
	return _lgr
func set_logger(logger):
	_lgr = logger
	_method_maker.set_logger(logger)

var _spy = null
func get_spy():
	return _spy
func set_spy(spy):
	_spy = spy

var _gut = null
func get_gut():
	return _gut
func set_gut(gut):
	_gut = gut

var _strategy = null
func get_strategy():
	return _strategy
func set_strategy(strategy):
	_strategy = strategy


var _method_maker = _utils.MethodMaker.new()
func get_method_maker():
	return _method_maker

var _ignored_methods = _utils.OneToMany.new()
func get_ignored_methods():
	return _ignored_methods

# ###############
# Private
# ###############
func _init(strategy=_utils.DOUBLE_STRATEGY.PARTIAL):
	set_logger(_utils.get_logger())
	_strategy = strategy

func _get_indented_line(indents, text):
	var to_return = ''
	for _i in range(indents):
		to_return += "\t"
	return str(to_return, text, "\n")


func _stub_to_call_super(obj_info, method_name):
	if(_utils.non_super_methods.has(method_name)):
		return

	var path = obj_info.get_path()
	if(obj_info.is_singleton()):
		path = obj_info.get_singleton_name()
	elif(obj_info.scene_path != null):
		path = obj_info.scene_path

	var params = _utils.StubParams.new(path, method_name, obj_info.get_subpath())
	params.to_call_super()
	_stubber.add_stub(params)


func _get_base_script_text(obj_info, override_path, script_methods):
	var path = obj_info.get_path()
	if(override_path != null):
		path = override_path

	var stubber_id = -1
	if(_stubber != null):
		stubber_id = _stubber.get_instance_id()

	var spy_id = -1
	if(_spy != null):
		spy_id = _spy.get_instance_id()

	var gut_id = -1
	if(_gut != null):
		gut_id = _gut.get_instance_id()

	var values = {
		# Top  sections
		"extends":obj_info.get_extends_text(),
		"constants":obj_info.get_constants_text(),
		"properties":obj_info.get_properties_text(),

		# metadata values
		"path":path,
		"subpath":obj_info.get_subpath(),
		"stubber_id":stubber_id,
		"spy_id":spy_id,
		"gut_id":gut_id,
		"singleton_name":_utils.nvl(obj_info.get_singleton_name(), ''),
		"is_partial":str(obj_info.make_partial_double).to_lower()
	}

	return _base_script_text.format(values)


func _create_double(obj_info, override_path=null):
	var script_methods = _get_methods(obj_info)
	var base_script = _get_base_script_text(obj_info, override_path, script_methods)
	var super_name = ""
	var path = ""

	if(obj_info.is_singleton()):
		super_name = obj_info.get_singleton_name()
	else:
		path = obj_info.get_path()

	var dbl = DoubledScript.new()

	dbl.append(base_script)

	# print('local method count = ', script_methods.local_methods.size())
	for i in range(script_methods.local_methods.size()):
		dbl.append(_get_func_text(script_methods.local_methods[i], path, super_name))

	# print('built-in method count = ', script_methods.built_ins.size())
	for i in range(script_methods.built_ins.size()):
		_stub_to_call_super(obj_info, script_methods.built_ins[i].name)
		dbl.append(_get_func_text(script_methods.built_ins[i], path, super_name))

	if(_print_source):
		print(dbl.get_contents())
	return dbl


func _double_scene_and_script(scene_info):
	var to_return = PackedSceneDouble.new()
	to_return.load_scene(scene_info.get_path())

	var inst = load(scene_info.get_path()).instantiate()
	var script_path = null
	if(inst.get_script()):
		script_path = inst.get_script().get_path()
	inst.free()

	if(script_path):
		var oi = ObjectInfo.new(script_path)
		oi.set_method_strategy(scene_info.get_method_strategy())
		oi.make_partial_double = scene_info.make_partial_double
		oi.scene_path = scene_info.get_path()
		to_return.set_script_obj(_double(oi, scene_info.get_path()).load_it())

	return to_return


func _get_methods(object_info):
	var obj = object_info.get_loaded_class()
	# any method in the script or super script
	var script_methods = ScriptMethods.new()
	var methods = obj.get_script_method_list()

	# if(!object_info.is_singleton() and !(obj is RefCounted)):
	# 	obj.free()

	# first pass is for local methods only
	for i in range(methods.size()):
		if(object_info.is_singleton()):
			#print(methods[i].name, " :: ", methods[i].flags, " :: ", methods[i].id)
			#print("    ", methods[i])

			# It appears that the ID for methods upstream from a singleton are
			# below 200.  Initially it was thought that singleton specific methods
			# were above 1000.  This was true for Input but not for OS.  I've
			# changed the condition to be > 200 instead of > 1000.  It will take
			# some investigation to figure out if this is right, but it works
			# for now.  Someone either find an issue and open a bug, or this will
			# just exist like this.  Sorry future me (or someone else).
			if(methods[i].id > 200 and methods[i].flags in [1, 9]):
				script_methods.add_local_method(methods[i])

		# 65 is a magic number for methods in script, though documentation
		# says 64.  This picks up local overloads of base class methods too.
		# See MethodFlags in @GlobalScope
		elif(!methods[i].name.begins_with('@') and !_ignored_methods.has(object_info.get_path(), methods[i]['name'])):
			script_methods.add_local_method(methods[i])

	if(object_info.get_method_strategy() == _utils.DOUBLE_STRATEGY.FULL):
		# second pass is for anything not local
		for j in range(methods.size()):
			# 65 is a magic number for methods in script, though documentation
			# says 64.  This picks up local overloads of base class methods too.
			if(methods[j].flags != 65 and !_ignored_methods.has(object_info.get_path(), methods[j]['name'])):
				script_methods.add_built_in_method(methods[j])

	return script_methods


func _get_inst_id_ref_str(inst):
	var ref_str = 'null'
	if(inst):
		ref_str = str('instance_from_id(', inst.get_instance_id(),')')
	return ref_str


func _get_func_text(method_hash, path, super_=""):
	var override_count = null;
	if(_stubber != null):
		override_count = _stubber.get_parameter_count(path, method_hash.name)

	var text = _method_maker.get_function_text(method_hash, path, override_count, super_) + "\n"

	return text


func _double(obj_info, override_path=null):
	var result = _create_double(obj_info, override_path)
	_double_count += 1
	return result


func _double_script(path, make_partial, strategy):
	var oi = ObjectInfo.new(path)
	oi.make_partial_double = make_partial
	oi.set_method_strategy(strategy)
	return _double(oi).load_it()


func _double_inner(path, subpath, make_partial, strategy):
	var oi = ObjectInfo.new(path, subpath)
	oi.set_method_strategy(strategy)
	oi.make_partial_double = make_partial
	var to_return = _double(oi).load_it()
	return to_return


func _double_scene(path, make_partial, strategy):
	var oi = ObjectInfo.new(path)
	oi.set_method_strategy(strategy)
	oi.make_partial_double = make_partial
	return _double_scene_and_script(oi)


func _double_gdnative(native_class, make_partial, strategy):
	var oi = ObjectInfo.new(null)
	oi.set_native_class(native_class)
	oi.set_method_strategy(strategy)
	oi.make_partial_double = make_partial
	return _double(oi).load_it()


func _double_singleton(singleton_name, make_partial, strategy):
	var oi = ObjectInfo.new(null)
	oi.set_singleton_name(singleton_name)
	oi.set_method_strategy(_utils.DOUBLE_STRATEGY.PARTIAL)
	oi.make_partial_double = make_partial
	return _double(oi).load_it()

# ###############
# Public
# ###############
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


# must always use FULL strategy since this is a native class and you won't get
# any methods if you don't use FULL
func double_gdnative(native_class):
	return _double_gdnative(native_class, false, _utils.DOUBLE_STRATEGY.FULL)


# must always use FULL strategy since this is a native class and you won't get
# any methods if you don't use FULL
func partial_double_gdnative(native_class):
	return _double_gdnative(native_class, true, _utils.DOUBLE_STRATEGY.FULL)


func double_singleton(name):
	return _double_singleton(name, false, _utils.DOUBLE_STRATEGY.PARTIAL)


func partial_double_singleton(name):
	return _double_singleton(name, true, _utils.DOUBLE_STRATEGY.PARTIAL)


func add_ignored_method(path, method_name):
	_ignored_methods.add(path, method_name)
