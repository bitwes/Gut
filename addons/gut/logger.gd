extends Node2D

var _gut = null

var types = {
	warn = 'WARNING',
	error = 'ERROR',
	info = 'INFO',
	debug = 'DEBUG',
	deprecated = 'DEPRECATED',
	normal = 'NORMAL'
}

var _types_enabled = {
	types.warn: true,
	types.error: true,
	types.info: true,
	types.debug: true,
	types.deprecated: true,
	types.normal: true
}

var _logs = {
	types.warn: [],
	types.error: [],
	types.info: [],
	types.debug: [],
	types.deprecated: [],
}

var _indent_level = 0
var _indent_string = '    '
var _skip_test_name_for_testing = false

var escape = PoolByteArray([0x1b]).get_string_from_ascii()
var CMD_COLORS  = {
	RED = escape + '[31m',
	YELLOW = escape + '[33m',
	DEFAULT = escape + '[0m',
	GREEN = escape + '[32m',
	UNDERLINE = escape + '[4m',
	BOLD = escape + '[1m'
}

func _format_for_type(type, text):
	if(!_types_enabled[type]):
		return null

	var to_return = text
	if(type != types.normal):
		_logs[type].append(text)
		# normal output line edings are decided by log and lograw but the other
		# types must have a newline added.
		to_return = str('[', type, ']  ', text, "\n")

	return to_return

func _indent_text(text):
	var to_return = text
	var ending_newline = ''

	if(text.ends_with("\n")):
		ending_newline = "\n"
		to_return = to_return.left(to_return.length() -1)

	var pad = ''
	for i in range(_indent_level):
		pad += _indent_string

	to_return = to_return.replace("\n", "\n" + pad)
	to_return += ending_newline

	return pad + to_return

# returns bool indicating if the passed in text was the test name so we can
# avoid printing the name multiple times.
func _print_test_name(text):

	if(text == '' or _gut == null or _skip_test_name_for_testing):
		return false

	var cur_test = _gut.get_current_test_object()
	if(cur_test == null):
		return false

	# suppress output if we haven't printed the test name yet and
	# what to print is the test name.
	var to_return = text == cur_test.name + "\n" && !cur_test.has_printed_name
	if(!cur_test.has_printed_name):
		_output("* " + cur_test.name + "\n")
		cur_test.has_printed_name = true

	return to_return

func _output(text):
	if(_gut):
		# this will keep the text indented under test for readability
		_gut.get_gui().get_text_box().insert_text_at_cursor(text)
		# IDEA!  We could store the current script and test that generated
		# this output, which could be useful later if we printed out a summary.

	if(_gut == null or _gut.get_should_print_to_console()):
		printraw(colorize_text(text))



func _log(type, text):
	var formatted = _format_for_type(type, text)
	if(formatted == null):
		return null
	var was_test_name = _print_test_name(text)
	formatted = _indent_text(formatted)

	if(!was_test_name):
		_output(formatted)

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

func log(text):
	return _log(types.normal, text + "\n")

func lograw(text):
	return _log(types.normal, text)

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

func get_indent_level():
	return _indent_level

func set_indent_level(indent_level):
	_indent_level = indent_level

func get_indent_string():
	return _indent_string

func set_indent_string(indent_string):
	_indent_string = indent_string

func clear():
	for key in _logs:
		_logs[key].clear()

func colorize_word(source, word, c):
	var new_word  = c + word + CMD_COLORS.DEFAULT
	return source.replace(word, new_word)

func colorize_text(text):
	var t = colorize_word(text, 'FAILED', CMD_COLORS.RED)
	t = colorize_word(t, 'PASSED', CMD_COLORS.GREEN)
	t = colorize_word(t, 'PENDING', CMD_COLORS.YELLOW)
	t = colorize_word(t, '[ERROR]', CMD_COLORS.RED)
	t = colorize_word(t, '[WARNING]', CMD_COLORS.YELLOW)
	t = colorize_word(t, '[DEBUG]', CMD_COLORS.BOLD)
	t = colorize_word(t, '[DEPRECATED]', CMD_COLORS.BOLD)
	t = colorize_word(t, '[INFO]', CMD_COLORS.BOLD)
	return t

func inc_indent():
	_indent_level += 1

func dec_indent():
	_indent_level = max(0, _indent_level -1)

func is_type_enabled(type):
	return _types_enabled[type]

func set_type_enabled(type, is_enabled):
	_types_enabled[type] = is_enabled