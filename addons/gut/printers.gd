# ------------------------------------------------------------------------------
# Interface and some basic functionality for all printers.
# ------------------------------------------------------------------------------
class Printer:
	var _format_enabled = true
	var _disabled = false

	func get_format_enabled():
		return _format_enabled

	func set_format_enabled(format_enabled):
		_format_enabled = format_enabled

	func send(text):
		if(_disabled):
			return

		if(_format_enabled):
			_output(format_text(text))
		else:
			_output(text)

	func get_disabled():
		return _disabled

	func set_disabled(disabled):
		_disabled = disabled

	# --------------------
	# Virtual Methods (some have some default behavior)
	# --------------------
	func _output(text):
		pass

	func format_text(text):
		return text

# ------------------------------------------------------------------------------
# Responsible for sending text to a GUT gui.
# ------------------------------------------------------------------------------
class GutGuiPrinter:
	extends Printer
	var _gut = null

	func _output(text):
		_gut.get_gui().get_text_box().insert_text_at_cursor(text)

	func get_gut():
		return _gut

	func set_gut(gut):
		_gut = gut

# ------------------------------------------------------------------------------
# This AND TerminalPrinter should not be enabled at the same time since it will
# result in duplicate output.  printraw does not print to the console so i had
# to make another one.  This will result in some extra newlines.
# ------------------------------------------------------------------------------
class ConsolePrinter:
	extends Printer

	func _output(text):
		# Could probably strip the last newline char here to keep things more
		# in line with the other printers.
		print(text)

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
		# Note, printraw does not print to the console.
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