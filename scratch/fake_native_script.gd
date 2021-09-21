extends SceneTree

func get_something():
	if(type_exists('Something')):
		return Something
	else:
		return 'poop'



func _init():
	print(type_exists('NativeScript'))

	print(NativeScript)
	var ns = NativeScript
	print('what is it now?:  ', ns)
	print('hello world')

	print(get_something())
	quit()