extends Node2D

var _warnings = []
var _errors = []
var _infos = []
var _debugs = []
var _deprecated = []
var _gut = null

var types = {
	warn = 'WARNING',
	error = 'ERROR',
	info = 'INFO',
	debug = 'DEBUG',
	deprecated = 'DEPRECATED'
}

var _suppress_output = false

func append_to(type, msg):
	if(type == types.warn):
		_warnings.append(msg)
	if(type == types.error):
		_errors.append(msg)
	if(type == types.info):
		_infos.append(msg)
	if(type == types.debug):
		_debugs.append(msg)
	if(type == types.deprecated):
		_deprecated.append(msg)

func _log(type, text):
	append_to(type, text)
	var formatted = str('[', type, ']  ', text)
	if(!_suppress_output):
		if(_gut):
			# this will keep the text indented under test for readability
			_gut.p(formatted)
		else:
			print(formatted)
	return formatted

func get_warnings():
	return _warnings

func get_errors():
	return _errors

func get_infos():
	return _infos

func get_debugs():
	return _debugs

func get_deprecated():
	return _deprecated

func warn(text):
	return _log(types.warn, text)

func error(text):
	return _log(types.error, text)

func info(text):
	return _log(types.info, text)

func debug(text):
	return _log(types.debug, text)

func deprecated(text, alt_method=null):
	var msg = text
	if(alt_method):
		msg = str('The method ', text, ' is deprecated, use ', alt_method , ' instead.')
	return _log(types.deprecated, msg)

func get_gut():
	return _gut

func set_gut(gut):
	_gut = gut

func clear():
	_warnings.clear()
	_errors.clear()
	_infos.clear()
	_debugs.clear()
	_deprecated.clear()
