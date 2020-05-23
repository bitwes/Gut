var _utils = load('res://addons/gut/utils.gd').get_instance()
var _params = null
var _call_count = 0
var _logger = null

func _init(params=null):
	_params = params
	_logger = _utils.get_logger()
	if(typeof(_params) != TYPE_ARRAY):
		_logger.error('You must pass an array to parameter_handler constructor.')
		_params = null

func get_current_parameters():
	_call_count += 1
	return _params[_call_count -1]

func is_done():
	var done = true
	if(_params != null):
		done = _call_count == _params.size()
	return done

func get_logger():
	return _logger

func set_logger(logger):
	_logger = logger
