# ##############################################################################
# This is a script I used to poke around script and method properties.  It's
# not supposed to be a "real" tool but it has a lot of examples in it and has
# come in handy numerous times.
#
# Feel free to use whatever you find in here for your own purposes.
# ##############################################################################
extends SceneTree

const DEFAULT_ARGS = 'default_args'
const NAME = 'name'
const ARGS = 'args'


class ExtendsNode2D:
	extends Node2D

	func my_function():
		return 7

	func get_position():
		return Vector2(0, 0)

class SimpleObject:
	var a = 'a'

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

	for i in range(methods.size()):
		print(methods[i]['name'])
		if(methods[i]['default_args'].size() > 0):
			print(" *** here be defaults ***")

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
	e.print_stray_nodes()

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


func _init():
	# var double_me = load('res://test/doubler_test_objects/double_me.gd').new()
	# print_method_info(double_me)
	# print("-------------\n-\n-\n-\n-------------")
	# var methods = get_methods_by_flag(double_me)
	# print_methods_by_flags(methods)

	#print_a_bunch_of_methods_by_flags()
	#var obj = ExtendsNode2D.new()
	#var obj = load('res://addons/gut/gut.gd').new()
	var obj = load('res://test/doubler_test_objects/double_extends_window_dialog.gd').new()
	#print_method_info(obj)
	print_method_info(obj)
	var methods = obj.get_method_list()

	for i in range(methods.size()):
		if(methods[i][DEFAULT_ARGS].size() > 0):
			pass#print(get_defaults_and_types(methods[i]))

	quit()
