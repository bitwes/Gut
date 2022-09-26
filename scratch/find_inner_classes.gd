extends SceneTree

var ThatInnerClassScript = load('res://test/resources/doubler_test_objects/inner_classes.gd')


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


func get_extends_text(inner, parent_script):
	if(parent_script.get_path() == ''):
		return null

	var to_return = null
	var inner_string = get_inner_class_string(inner, parent_script)
	if(inner_string != null):
		to_return = str("extends '", parent_script.get_path(), "'.", inner_string)

	return to_return


func get_inner_class_string(inner, parent_script):

	var const_map = parent_script.get_script_constant_map()
	var consts = const_map.keys()
	var const_idx = 0
	var found = false
	var to_return = null

	while(const_idx < consts.size() and !found):
		var key = consts[const_idx]
		var thing = const_map[key]

		if(typeof(thing) == TYPE_OBJECT):
			if(thing == inner):
				found = true
				to_return = key
			else:
				to_return = get_inner_class_string(inner, thing)
				if(to_return != null):
					to_return = str(key, '.', to_return)
					found = true

		const_idx += 1

	return to_return



func _init():
	var result = get_inner_class_string(HasSomeInners.Inner2.Inner2_b, self.get_script())
	print(result)

	print()
	result = get_inner_class_string(ThatInnerClassScript.InnerWithSignals, ThatInnerClassScript)
	print(result)

	print(get_extends_text(HasSomeInners.Inner2.Inner2_b, self.get_script()))

	print(get_extends_text(HasSomeInners.Inner2.Inner2_b, HasSomeInners))

	print(get_extends_text(ThatInnerClassScript.InnerWithSignals, ThatInnerClassScript))

	quit()