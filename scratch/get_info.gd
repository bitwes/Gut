# ##############################################################################
# This is a script I used to poke around script and method properties.  It's
# not supposed to be a "real" tool but it has a lot of examples in it and has
# come in handy numerous times.
#
# Feel free to use whatever you find in here for your own purposes.
# ##############################################################################
extends SceneTree

const DOUBLE_ME_PATH = 'res://test/resources/doubler_test_objects/double_me.gd'
var DoubleMe = load(DOUBLE_ME_PATH)
var DoubleMeScene = load('res://test/resources/doubler_test_objects/double_me_scene.tscn')
var SetGetTestNode = load('res://test/resources/test_assert_setget_test_objects/test_node.gd')
var json = JSON.new()
var _strutils = load('res://addons/gut/strutils.gd').new()

const DEFAULT_ARGS = 'default_args'
const NAME = 'name'
const ARGS = 'args'


class HasSomeInners:
	signal look_at_me_now

	const WHATEVER = 'maaaaaan'

	class Inner1:
		extends 'res://addons/gut/test.gd'
		var a = 'b'

	class Inner2:
		var b = 'a'

		class Inner2_a:
			extends 'res://addons/gut/test.gd'

		class Inner2_b:
			var foo = 'bar'

	class Inner3:
		extends 'res://test/gut_test.gd'

	class ExtendsInner1:
		extends Inner1

class ExtendsNode2D:
	extends Node2D

	static func a_static_func():
		return true

	func my_function():
		return 7

	func get_position():
		return Vector2(0, 0)

class SimpleObject:
	var a = 'a'


class ExtendsAnInnerClassElsewhere:
	extends 'res://test/resources/doubler_test_objects/inner_classes.gd'.InnerB

	func foobar():
		return 'foobar'

func get_methods_by_flag(obj):
	var methods_by_flags = {}
	var methods = obj.get_method_list()

	for i in range(methods.size()):
		var flag = methods[i]['flags']
		var name = methods[i]['name']
		if(methods_by_flags.has(flag)):
			methods_by_flags[flag].append(name)
		else:
			methods_by_flags[flag] = [name]
	return methods_by_flags


func print_methods_by_flags(methods_by_flags):

	for flag in methods_by_flags:
		for i in range(methods_by_flags[flag].size()):
			print(flag, ":  ", methods_by_flags[flag][i])

	var total = 0
	for flag in methods_by_flags:
		if(methods_by_flags[flag].size() > 0):
			print("-- ", flag, " (", methods_by_flags[flag].size(), ") --")
			total += methods_by_flags[flag].size()
	print("Total:  ", total)


func subtract_dictionary(sub_this, from_this):
	var result = {}
	for key in sub_this:
		if(from_this.has(key)):
			result[key] = []

			for value in from_this[key]:
				var index = sub_this[key].find(value)
				if(index == -1):
					result[key].append(value)
	return result


func print_method_info(obj):
	var methods = obj.get_method_list()
	print('methods = ',   methods)
	for i in range(methods.size()):
		print(methods[i]['name'])
		if(methods[i]['default_args'].size() > 0):
			print(" *** here be defaults ***")

		if(methods[i]['flags'] == 65):
			for key in methods[i]:
				if(key == 'args'):
					print('  args:')
					for argname in range(methods[i][key].size()):
						print('    ',  methods[i][key][argname]['name'], ':  ', methods[i][key][argname])
				else:
					print('  ', key, ':  ', methods[i][key])


func print_a_bunch_of_methods_by_flags():
	var e = ExtendsNode2D.new()
	var n = get_methods_by_flag(e)
	# print_methods_by_flags(n)

	var s = SimpleObject.new()
	var o = get_methods_by_flag(s)
	# print_methods_by_flags(o)

	#print_methods_by_flags(subtract_dictionary(n, o))
	print("\n\n\n")
	print_methods_by_flags(subtract_dictionary(o, n))
	print("strays  ")
	e.print_orphan_nodes()


func get_defaults_and_types(method_meta):
	var text = ""
	text += method_meta[NAME] + "\n"
	for i in range(method_meta[DEFAULT_ARGS].size()):
		var arg_index = method_meta[ARGS].size() - (method_meta[DEFAULT_ARGS].size() - i)
		text += str('  ', method_meta[ARGS][arg_index][NAME])
		text += str('(type=', method_meta[ARGS][arg_index]['type'], ")")
		text += str(' = ', method_meta[DEFAULT_ARGS][i], "\n")
		# text += str('  ', method_meta[ARGS][arg_index]['usage'], "\n")
	return text


func class_db_stuff():
	print(ClassDB.class_exists('Node2D'))
	#print('category = ',  ClassDB.('Node2D'))
	#print(str(JSON.print(ClassDB.class_get_method_list('Node2D'), ' ')))
	# print(ClassDB.class_get_integer_constant_list('Node2D'))
	# print(ClassDB.get_class_list())


func _init_other():
	var  dm   = DoubleMe.new()
	var props = dm.get_property_list()
	print(str(props))
	print(str(dm.get_meta_list()))
	print('class = ', dm.get_class())
	print('script = ', dm.get_script())
	print(dm.get_script().get_path())
	print(dm)
	quit()

func does_inherit_from_test(thing):
	var base_script = thing.get_base_script()
	var to_return = false
	print('  *base_script = ', base_script)
	if(base_script != null):
		var base_path = base_script.get_path()
		print('  *base_path = ', base_path)
		if(base_path == 'res://addons/gut/test.gd'):
			to_return = true
		else:
			to_return = does_inherit_from_test(base_script)
	return to_return

func print_other_info(loaded, msg = '', indent=''):
	print(indent, '--------------------- ', msg, ' ---------------------')
	print(indent, loaded)

	var base_script_path = 'NO base script'
	if(loaded.has_method('get_base_script')):
		if(loaded.get_base_script() != null):
			base_script_path = str('"', loaded.get_base_script().get_path(), '"')
		else:
			base_script_path = 'Null base script'

	print(indent, 'base_script path          ', base_script_path)
	print(indent, 'class                     ', loaded.get_class())
	print(indent, 'instance base type        ', loaded.get_instance_base_type())
	print(indent, 'instance_id               ', loaded.get_instance_id())
	print(indent, 'meta_list                 ', loaded.get_meta_list())
	print(indent, 'name                      ', loaded.get_name())
	print(indent, 'path                      ', loaded.get_path())
	print(indent, 'resource local to scene   ', loaded.resource_local_to_scene)
	print(indent, 'resource name             ', loaded.resource_name)
	print(indent, 'resource path             ', loaded.resource_path)
	print(indent, 'RID                       ', loaded.get_rid())
	print(indent, 'script                    ', loaded.get_script())
	print()


	var const_map = loaded.new().get_script().get_script_constant_map()
	if(const_map.size() > 0):
		print(indent, '--- Constants ---')
	for key in const_map:
		var thing = const_map[key]
		print(indent, key, ' = ', thing)
		if(typeof(thing) == TYPE_OBJECT):
			print_other_info(thing, key, indent + '    ')
			# print('  ', 'meta         ', thing.get_meta_list())
			# print('  ', 'class        ', thing.get_class())
			# print('  ', 'path         ', thing.get_path())
			# var base_script = thing.get_base_script()
			# print('  ', 'base script  ', base_script)
			# if(base_script != null):
			# 	print('  ', 'base id      ', base_script.get_instance_id())
			# 	print('  ', 'base path    ', base_script.get_path() )
			# print('  ', 'base type    ', thing.get_instance_base_type())
			# print('  ', 'can instantiate ', thing.can_instantiate())
			# print('  ', 'id           ', thing.get_instance_id())
			# print('  ', 'is test      ', does_inherit_from_test(thing))



func print_inner_test_classes(loaded, from=null):
	# print('path = ', loaded.get_path())
	# if(loaded.get_base_script() != null):
	# 	print('base = ', loaded.get_base_script().get_path())
	# else:
	# 	print('base = ')

	var const_map = loaded.get_script_constant_map()
	for key in const_map:
		var thing = const_map[key]

		if(typeof(thing) == TYPE_OBJECT):
			print('Class ', key, ':')
			if(does_inherit_from_test(thing)):
				print('  is a test class')
			else:
				print('  noooooooooope')
			var next_from
			if(from == null):
				next_from = key
			else:
				next_from = str(from, '/', key)
			print_inner_test_classes(thing, next_from)

		else:
			print('CONST ', key, ' = ', thing)


func print_script_methods():
	var script = load('res://tests_4_0/test_print.gd')

	var methods = script.get_script_method_list()
	for i in range(methods.size()):
		print(methods[i]['name'])
		pp(methods[i])


func print_methods(methods, print_all_meta = false):
	var methods_by_name = {}
	var method_names = []
	for method in methods:
		methods_by_name[method.name] = method
		method_names.append(method.name)

	method_names.sort()

	for m_name in method_names:

		print(m_name)
		if(print_all_meta):
			pp(methods_by_name[m_name], '  ')


func print_properties(props, thing, print_all_meta=false):
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


func print_all_info(thing):
	print('path = ', thing.get_path())

	print('--- Methods (object) ---')
	print_methods(thing.get_method_list())

	print('--- Methods (script) ---')
	print_methods(thing.get_script_method_list())

	print('--- Properties (object) ---')
	var props = thing.get_property_list()
	print_properties(props, thing)

	print('--- Properties (script) ---')
	props = thing.get_script_property_list()
	print_properties(props, thing, true)

	print('--- Constants ---')
	print_inner_test_classes(thing)

	print('--- Signals ---')
	var sigs = thing.get_signal_list()
	for sig in sigs:
		print(sig['name'])
		print('  ', sig)

func print_class_db_class_list():
	var list = ClassDB.get_class_list()
	list.sort()
	print("\n".join(list))

func pp(dict, indent=''):
	var text = json.stringify(dict, '  ')
	text = _strutils.indent_text(text, 1, indent)
	print(text)

func has_script_method(Class):
	var methods = Class.get_script_method_list()

func print_inner_classes(loaded, parent=''):
	var const_map = loaded.get_script_constant_map()

	for key in const_map:
		var thing = const_map[key]

		if(typeof(thing) == TYPE_OBJECT):
			print(parent, key, ':  ', thing)
			print_inner_classes(thing, key + '.')

func print_inner_class_path(loaded):
	pass


func _init():
	var ThatInnerClassScript = load('res://test/resources/doubler_test_objects/inner_classes.gd')
	# print_other_info(HasSomeInners, 'HasSomeInners')
	# print_other_info(HasSomeInners.Inner2.Inner2_a, 'Inner2_a')
	# print_inner_classes(ThatInnerClassScript)
	# print_other_info(ThatInnerClassScript, 'ThatInnerClassScript')
	print_other_info(ThatInnerClassScript.AnotherInnerA, 'AnotherInnerA')
	print_all_info(ThatInnerClassScript.AnotherInnerA)
	# print_all_info(ExtendsAnInnerClassElsewhere)
	# print_all_info(DoubleMe)

	# print_class_db_class_list()

	# print_other_info(HasSomeInners)
	# print_other_info(HasSomeInners.Inner1)


	# print_all_info(GutTest)
	# print_all_info(SetGetTestNode)
	# print(SetGetTestNode.has_method('has_setter_setter'))
	# var inst = SetGetTestNode.new()
	# print(inst.has_method('has_setter_setter'))
	# print(inst.has_method('@has_setter_setter'))
	# print(inst.has_method('@has_getter_getter'))

	# class_db_stuff()

	# var r = RefCounted.new()
	# var r2 = r
	# var r3 = r
	# var r4 = r
	# print_all_info(r)


	#print(r.get('RefCounted'))

	# print_all_info(HasSomeInners)
	# print_all_info(DoubleMe)
	# var dm = DoubleMe.new()
	# get_root().add_child(dm)
	# var result = await dm.might_await_no_return()
	# dm.might_await_no_return()
	# dm.uses_await_response()

	# pp(DoubleMe.get_script_method_list())
	# var flag_methods = get_methods_by_flag(DoubleMe)
	# print_methods_by_flags(flag_methods)
	#print(DoubleMeScene.script)
	#print(DoubleMeScene.resource_name)
	# print(DoubleMeScene.get_meta_list())

	# print_script_methods()
	#var test = load('res://addons/gut/test.gd').new()
	#print_method_info(test)

	# var inners = load('res://test/resources/parsing_and_loading_samples/test_only_inner_classes.gd')
	# print_other_info(inners)
	# print('-----')
	# print_other_info(HasSomeInners)
	# print_other_info(load('res://test/gut_test.gd'))
	#print_other_info(load('res://test/unit/test_test_collector.gd'))

	# print_inner_test_classes(load('res://test/unit/test_test_collector.gd'))
	# print("\n\n\n")
	# print_inner_test_classes(HasSomeInners)
	# print("\n\n\n")
	# print_inner_test_classes(load('res://scratch/get_info.gd'))

	# print_inner_test_classes(load('res://test/unit/test_doubler.gd'))
	#print_inner_test_classes(HasSomeInners)
	#print_other_info(HasSomeInners)
	#print_other_info(HasSomeInners.ExtendsInner1)

	# var double_me = load('res://test/resources/doubler_test_objects/double_me.gd')
	# print_method_info(double_me)
	# print_method_info(double_me.new())
	# print("-------------\n-\n-\n-\n-------------")
	# var methods = get_methods_by_flag(double_me)
	# print_methods_by_flags(methods)

	#print_a_bunch_of_methods_by_flags()
	#var obj = RayCast2D.new() #ExtendsNode2D.new()
	#var obj = load('res://addons/gut/gut.gd').new()
	#var obj = load('res://test/resources/doubler_test_objects/double_extends_window_dialog.gd').new()
	#ExtendsNode2D.set_meta('gut_ignore', 'something')
	#print_method_info(obj)
	# print_method_info(CodeTextEditor)
	# print(CodeTextEditor.new().get_property_list())
	#print(obj.get_meta_list())
	#print(ExtendsNode2D.get_meta_list())
	#print_method_info(ExtendsNode2D)

	#var _methods = obj.get_method_list()
	#print(str(JSON.print(methods, ' ')))
	# for i in range(methods.size()):
	# 	if(methods[i][DEFAULT_ARGS].size() > 0):
	# 		pass#print(get_defaults_and_types(methods[i]))

	quit()
