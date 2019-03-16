extends Node2D

var _gut = null

var types = {
	warn = 'WARNING',
	error = 'ERROR',
	info = 'INFO',
	debug = 'DEBUG',
	deprecated = 'DEPRECATED'
}

var _logs = {
	types.warn: [],
	types.error: [],
	types.info: [],
	types.debug: [],
	types.deprecated: []
}

var _suppress_output = false

func _gut_log_level_for_type(log_type):
	if(log_type == types.warn or log_type == types.error or log_type == types.deprecated):
		return 0
	else:
		return 2

func _log(type, text):
	_logs[type].append(text)
	var formatted = str('[', type, ']  ', text)
	if(!_suppress_output):
		if(_gut):
			# this will keep the text indented under test for readability
			_gut.p(formatted, _gut_log_level_for_type(type))
			# IDEA!  We could store the current script and test that generated
			# this output, which could be useful later if we printed out a summary.
		else:
			print(formatted)
	return formatted

# ---------------
# Get Methods
# ---------------
func get_warnings():
	return get_log_entries(types.warn)

func get_errors():
	return get_log_entries(types.error)

func get_infos():
	return get_log_entries(types.info)

func get_debugs():
	return get_log_entries(types.debug)

func get_deprecated():
	return get_log_entries(types.deprecated)

func get_count(log_type=null):
	var count = 0
	if(log_type == null):
		for key in _logs:
			count += _logs[key].size()
	else:
		count = _logs[log_type].size()
	return count

func get_log_entries(log_type):
	return _logs[log_type]

# ---------------
# Log methods
# ---------------
func warn(text):
	return _log(types.warn, text)

func error(text):
	return _log(types.error, text)

func info(text):
	return _log(types.info, text)

func debug(text):
	return _log(types.debug, text)

# supply some text or the name of the deprecated method and the replacement.
func deprecated(text, alt_method=null):
	var msg = text
	if(alt_method):
		msg = str('The method ', text, ' is deprecated, use ', alt_method , ' instead.')
	return _log(types.deprecated, msg)

# ---------------
# Misc
# ---------------
func get_gut():
	return _gut

func set_gut(gut):
	_gut = gut

func clear():
	for key in _logs:
		_logs[key].clear()
