extends SceneTree

class LazyLoader:
	var _loaded = null
	var _inst = null
	var _path = null

	func _init(path):
		_path = path


	func get_loaded():
		if(_loaded == null):
			print('---- loading ', _path, ' ----')
			_loaded = load(_path)
		return _loaded


	func get_instance():
		if(_inst == null):
			print('---- creating instance of ', _path, ' ----')
			_inst = get_loaded().new()
		return _inst




class UseLazyLoader:

	var AutoFree = LazyLoader.new('res://addons/gut/autofree.gd') :
		get: return AutoFree.get_loaded()
		set(val): pass
	var Awaiter = LazyLoader.new('res://addons/gut/awaiter.gd'):
		get: return Awaiter.get_loaded()
		set(val): pass
	var Comparator = LazyLoader.new('res://addons/gut/comparator.gd'):
		get: return Comparator.get_loaded()
		set(val): pass
	var CompareResult = LazyLoader.new('res://addons/gut/compare_result.gd'):
		get: return CompareResult.get_loaded()
		set(val): pass
	var Logger = LazyLoader.new('res://addons/gut/logger.gd') :
		get: return Logger.get_loaded()
		set(val): pass

	var lgr = LazyLoader.new('res://addons/gut/logger.gd'):
		get: return lgr.get_instance()
		set(val): pass




func _init():
	var ull = UseLazyLoader.new()
	print(ull.AutoFree)
	print(ull.AutoFree.new())
	ull.lgr.warn("It might break")
	ull.lgr.error('It broke')
	print(ull.Comparator.new())
	print('lgr is a Logger instance = ', is_instance_of(ull.lgr, ull.Logger))
	quit()