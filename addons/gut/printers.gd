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

	func send(text, fmt=null):
		if(_disabled):
			return

		if(fmt != null and _format_enabled):
			_output(format_text(text, fmt))
		else:
			_output(text)

	func get_disabled():
		return _disabled

	func set_disabled(disabled):
		_disabled = disabled

	func raw_color(text, color_name):
		return text
	# --------------------
	# Virtual Methods (some have some default behavior)
	# --------------------
	func _output(text):
		pass

	func format_text(text, fmt):
		return text

# ------------------------------------------------------------------------------
# Responsible for sending text to a GUT gui.
# ------------------------------------------------------------------------------
class GutGuiPrinter:
	extends Printer
	var _gut = null

	func _bold(source, word):
		var new_word = '[b]' + word + '[/b]'
		return source.replace(word, new_word)

	func _underline(source, word):
		var new_word = '[u]' + word + '[/u]'
		return source.replace(word, new_word)

	func _color_text(text, c_word):
		return '[color=' + c_word + ']' + text + '[/color]'

	func format_text(text, fmt):
		if(fmt == 'bold' or fmt == 'underline'):
			return text
		else:
			return _color_text(text, fmt)

	func _output(text):
		#_gut.get_gui().get_text_box().insert_text_at_cursor(text)
		_gut.get_gui().get_text_box().append_bbcode(text)

	func get_gut():
		return _gut

	func set_gut(gut):
		_gut = gut

# ------------------------------------------------------------------------------
# This AND TerminalPrinter should not be enabled at the same time since it will
# result in duplicate output.  printraw does not print to the console so i had
# to make another one.
# ------------------------------------------------------------------------------
class ConsolePrinter:
	extends Printer
	var _buffer = ''

	# suppresses output until it encounters a newline to keep things
	# inline as much as possible.
	func _output(text):
		if(text.ends_with("\n")):
			print(_buffer + text.left(text.length() -1), '(console)')
			_buffer = ''
		else:
			_buffer += text

# ------------------------------------------------------------------------------
# Prints text to terminal, formats some words.
# ------------------------------------------------------------------------------
class TerminalPrinter:
	extends Printer

	var escape = PoolByteArray([0x1b]).get_string_from_ascii()
	var cmd_colors  = {
		red = escape + '[31m',
		yellow = escape + '[33m',
		green = escape + '[32m',

		underline = escape + '[4m',
		bold = escape + '[1m',

		default = escape + '[0m',
	}

	func _output(text):
		# Note, printraw does not print to the console.
		printraw(text)

	func format_text(text, fmt):
		return cmd_colors[fmt] + text + cmd_colors.default
