# ------------------------------------------------------------------------------
# Static
#
# We could add a "load all" if we want a definitive point in running tests where
# everything has been loaded.
# ------------------------------------------------------------------------------
static var usage_counter = load('res://addons/gut/thing_counter.gd').new()




# ------------------------------------------------------------------------------
# Class
# ------------------------------------------------------------------------------
var _loaded = null
var _inst = null
var _path = null

func _init(path):
	_path = path
	usage_counter.add_thing_to_count(path)


func get_loaded():
	if(_loaded == null):
		print('---- loading ', _path, ' ----')
		_loaded = load(_path)
	usage_counter.add(_path)
	return _loaded


func get_instance():
	if(_inst == null):
		print('---- creating instance of ', _path, ' ----')
		_inst = get_loaded().new()
	return _inst
