# ------------------------------------------------------------------------------
# Static
#
# We could add a "load all" if we want a definitive point in running tests where
# everything has been loaded.
# ------------------------------------------------------------------------------
static var usage_counter = load('res://addons/gut/thing_counter.gd').new()
static var WarningsManager = load('res://addons/gut/warnings_manager.gd')

static var reload_scripts = true
static var _wm = WarningsManager.new()

static func load_script_ignoring_all_warnings(path):
	return load_script_using_custom_warnings(path, _wm.create_ignore_all_dictionary())


static func load_script_using_custom_warnings(path, warnings_dictionary):
	var should_reload = reload_scripts and ResourceLoader.has_cached(path)
	var current_warns = _wm.create_warnings_dictionary_from_project_settings()

	_wm.apply_warnings_dictionary(warnings_dictionary)
	var s = load(path)
	if(should_reload):
		s.reload()
	_wm.apply_warnings_dictionary(current_warns)

	return s



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
