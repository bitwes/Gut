# ------------------------------------------------------------------------------
# Interface and some basic functionality for all printers.
# ------------------------------------------------------------------------------
class Printer:
	var _format_enabled = true
	var _disabled = false
	var _printer_name = 'NOT SET'
	var _show_name = false # used for debugging, set manually

	func get_format_enabled():
		return _format_enabled

	func set_format_enabled(format_enabled):
		_format_enabled = format_enabled

	func send(text, fmt=null):
		if(_disabled):
			return

		var formatted = text
		if(fmt != null and _format_enabled):
			formatted = format_text(text, fmt)

		if(_show_name):
			formatted = str('(', _printer_name, ')') + formatted

		_output(formatted)

	func get_disabled():
		return _disabled

	func set_disabled(disabled):
		_disabled = disabled

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
	# so, getting the bbcode out of the rich text label is impossible.  So
	# we build a buffer of it as we go.  This works, but it stinks we have
	# to do it this way.
	var _buffer = ""
	var _use_buffer = true

	var _colors = {
			red = Color.red,
			yellow = Color.yellow,
			green = Color.green
	}

	func _init():
		_printer_name = 'gui'

	func _add_bbcode(bbcode):
		var box = _gut.get_gui().get_text_box()
		box.append_bbcode(bbcode)
		if(_use_buffer):
			_buffer += bbcode


	func _wrap_with_tag(text, tag):
		return str('[', tag, ']', text, '[/', tag, ']')

	func _color_text(text, c_word):
		return '[color=' + c_word + ']' + text + '[/color]'

	func format_text(text, fmt):
		var box = _gut.get_gui().get_text_box()

		if(fmt == 'bold'):
			_add_bbcode(str('[b]', text, '[/b]'))
		elif(fmt == 'underline'):
			_add_bbcode(str('[u]', text, '[/u]'))
		elif(_colors.has(fmt)):
			_add_bbcode(_color_text(text, fmt))
		else:
			_add_bbcode(text)

		return ''

	func _output(text):
		_add_bbcode(text)

	func get_gut():
		return _gut

	func set_gut(gut):
		_gut = gut

	# This can be very very slow when the box has a lot of text, and won't work
	# with the buffer.  I don't think it is actually being used though.
	func clear_line():
		var box = _gut.get_gui().get_text_box()
		box.remove_line(box.get_line_count() - 1)
		box.update()

	func get_bbcode():
		if(_use_buffer):
			return _buffer
		else:
			return _gut.get_gui().get_text_box().text

	func set_use_buffer(value):
		_use_buffer = value

	func get_use_buffer():
		return _use_buffer

# ------------------------------------------------------------------------------
# This AND TerminalPrinter should not be enabled at the same time since it will
# result in duplicate output.  printraw does not print to the console so i had
# to make another one.
# ------------------------------------------------------------------------------
class ConsolePrinter:
	extends Printer
	var _buffer = ''

	func _init():
		_printer_name = 'console'

	# suppresses output until it encounters a newline to keep things
	# inline as much as possible.
	func _output(text):
		if(text.ends_with("\n")):
			print(_buffer + text.left(text.length() -1))
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

		clear_line = escape + '[2K'
	}

	func _init():
		_printer_name = 'terminal'

	func _output(text):
		# Note, printraw does not print to the console.
		printraw(text)

	func format_text(text, fmt):
		return cmd_colors[fmt] + text + cmd_colors.default

	func clear_line():
		send(cmd_colors.clear_line)

	func back(n):
		send(escape + str('[', n, 'D'))

	func forward(n):
		send(escape + str('[', n, 'C'))
