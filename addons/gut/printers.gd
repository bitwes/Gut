# ------------------------------------------------------------------------------
# Interface and some basic functionality for all printers.
# ------------------------------------------------------------------------------
class Printer:
	var _format_enabled = true

	func get_format_enabled():
		return _format_enabled

	func set_format_enabled(format_enabled):
		_format_enabled = format_enabled

	func send(text):
		if(_format_enabled):
			_output(format_text(text))
		else:
			_output(text)

	func _output(text):
		pass

	func format_text(text):
		pass

# ------------------------------------------------------------------------------
# Responsible for sending text to a GUT gui.
# ------------------------------------------------------------------------------
class GutGuiPrinter:
	extends Printer
	var _gut = null

	func _output(text):
		_gut.get_gui().get_text_box().insert_text_at_cursor(text)

	func format_text(text):
		return text

	func get_gut():
		return _gut

	func set_gut(gut):
		_gut = gut

# ------------------------------------------------------------------------------
# Prints text to terminal, formats some words.
# ------------------------------------------------------------------------------
class TerminalPrinter:
	extends Printer

	var escape = PoolByteArray([0x1b]).get_string_from_ascii()
	var CMD_COLORS  = {
		RED = escape + '[31m',
		YELLOW = escape + '[33m',
		DEFAULT = escape + '[0m',
		GREEN = escape + '[32m',
		UNDERLINE = escape + '[4m',
		BOLD = escape + '[1m'
	}

	func _output(text):
		printraw(text)

	func _colorize_word(source, word, c):
		var new_word  = c + word + CMD_COLORS.DEFAULT
		return source.replace(word, new_word)

	func _colorize_text(text):
		var t = _colorize_word(text, 'FAILED', CMD_COLORS.RED)
		t = _colorize_word(t, 'PASSED', CMD_COLORS.GREEN)
		t = _colorize_word(t, 'PENDING', CMD_COLORS.YELLOW)
		t = _colorize_word(t, '[ERROR]', CMD_COLORS.RED)
		t = _colorize_word(t, '[WARNING]', CMD_COLORS.YELLOW)
		t = _colorize_word(t, '[DEBUG]', CMD_COLORS.BOLD)
		t = _colorize_word(t, '[DEPRECATED]', CMD_COLORS.BOLD)
		t = _colorize_word(t, '[INFO]', CMD_COLORS.BOLD)
		return t

	func format_text(text):
		return _colorize_text(text)