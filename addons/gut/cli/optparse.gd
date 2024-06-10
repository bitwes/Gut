#-------------------------------------------------------------------------------
# Holds all the properties of a command line option
#-------------------------------------------------------------------------------
class Option:
	static var empty_value = &'--__this_is_an_optparse_empty_value__--'

	var _value = empty_value
	var value = empty_value:
		get:
			if(str(_value) == empty_value):
				return default
			else:
				return _value
		set(val):
			_value = val

	var option_name = ''
	var default = null
	var description = ''
	var required = false

	func _init(name,default_value,desc=''):
		option_name = name
		default = default_value
		description = desc
		value = empty_value


	func pad(to_pad, size, pad_with=' '):
		var to_return = to_pad
		for _i in range(to_pad.length(), size):
			to_return += pad_with

		return to_return


	func to_s(min_space=0):
		var subbed_desc = description
		if(subbed_desc.find('[default]') != -1):
			subbed_desc = subbed_desc.replace('[default]', str(default))
		return pad(option_name, min_space) + subbed_desc


	func has_been_set():
		return str(_value) != empty_value


#-------------------------------------------------------------------------------
# A struct for organizing options by a heading
#-------------------------------------------------------------------------------
class OptionHeading:
	var options = []
	var display = 'default'

#-------------------------------------------------------------------------------
# Organizes options by order, heading, position.  Also responsible for all
# help related text generation.
#-------------------------------------------------------------------------------
class Options:
	var options = []
	var positional = []
	var default_heading = OptionHeading.new()
	var script_option = Option.new('-s', '?', 'script option provided by Godot')

	var _options_by_name = {}
	var _options_by_heading = [default_heading]
	var _cur_heading = default_heading


	func add_heading(display):
		var heading = OptionHeading.new()
		heading.display = display
		_cur_heading = heading
		_options_by_heading.append(heading)


	func add(option):
		options.append(option)
		_options_by_name[option.option_name] = option
		_cur_heading.options.append(option)


	func add_positional(option):
		positional.append(option)
		_options_by_name[option.option_name] = option


	func get_by_name(option_name):
		var found_param = null
		if(option_name == script_option.option_name):
			found_param = script_option
		elif(_options_by_name.has(option_name)):
			found_param = _options_by_name[option_name]

		return found_param


	func get_help_text():
		var longest = 0
		var text = ""
		for i in range(options.size()):
			if(options[i].option_name.length() > longest):
				longest = options[i].option_name.length()

		for heading in _options_by_heading:
			if(heading != default_heading):
				text += str("\n", heading.display, "\n")
			for option in heading.options:
				text += str('  ', option.to_s(longest + 2), "\n")


		return text


	func get_option_value_text():
		var text = ""
		for option in options:
			text += str(option.option_name, ' = ', option.value)

			if(!option.has_been_set()):
				text += " (default)"
			text += "\n"
		return text


	func print_option_values():
		print(get_option_value_text())


	func get_missing_required_options():
		var to_return = []
		for opt in options:
			if(opt.required and !opt.has_been_set()):
				to_return.append(opt)

		for opt in positional:
			if(opt.required and !opt.has_been_set()):
				to_return.append(opt)

		return to_return


	func get_usage_text():
		var pos_text = ""
		for opt in positional:
			pos_text += str("[", opt.description, "] ")

		if(pos_text != ""):
			pos_text += " [opts] "

		return "<path to godot> -s " + script_option.value + " [opts] " + pos_text






#-------------------------------------------------------------------------------
# The high level interface between this script and the command line options
# supplied.  Uses Option class and CmdLineParser to extract information from
# the command line and make it easily accessible.
#-------------------------------------------------------------------------------
var options = Options.new()
var banner = ''
var option_name_prefix = '-'
var unused = []


func _convert_value_to_array(raw_value):
	var split = raw_value.split(',')
	# This is what an empty set looks like from the command line.  If we do
	# not do this then we will always get back [''] which is not what it
	# shoudl be.
	if(split.size() == 1 and split[0] == ''):
		split = []
	return split


# REMEMBER raw_value not used for bools.
func _set_option_value(option, raw_value):
	var t = typeof(option.default)
	# only set values that were specified at the command line so that
	# we can punch through default and config values correctly later.
	# Without this check, you can't tell the difference between the
	# defaults and what was specified, so you can't punch through
	# higher level options.
	if(t == TYPE_INT):
		option.value = int(raw_value)
	elif(t == TYPE_STRING):
		option.value = str(raw_value)
	elif(t == TYPE_ARRAY):
		option.value = _convert_value_to_array(raw_value)
	elif(t == TYPE_BOOL):
		option.value = !option.default
	elif(t == TYPE_FLOAT):
		option.value = float(raw_value)
	elif(t == TYPE_NIL):
		print(option.option_name + ' cannot be processed, it has a nil datatype')
	else:
		print(option.option_name + ' cannot be processed, it has unknown datatype:' + str(t))


func _is_option(arg):
	return arg.begins_with(option_name_prefix)


func _parse_command_line_arguments(args):
	var parsed_opts = args.duplicate()
	var i = 0
	var positional_index = 0

	while i < parsed_opts.size():
		var opt  = ''
		var value = ''
		var entry = parsed_opts[i]

		if(_is_option(entry)):
			if(entry.find('=') != -1):
				var parts = entry.split('=')
				opt = parts[0]
				value = parts[1]
				var the_option = options.get_by_name(opt)
				if(the_option != null):
					parsed_opts.remove_at(i)
					_set_option_value(the_option, value)
				else:
					i += 1
			else:
				var the_option = options.get_by_name(entry)
				if(the_option != null):
					parsed_opts.remove_at(i)
					if(typeof(the_option.default) == TYPE_BOOL):
						_set_option_value(the_option, null)
					elif(i < parsed_opts.size() and !_is_option(parsed_opts[i])):
						value = parsed_opts[i]
						parsed_opts.remove_at(i)
						_set_option_value(the_option, value)
				else:
					i += 1
		else:
			if(positional_index < options.positional.size()):
				_set_option_value(options.positional[positional_index], entry)
				parsed_opts.remove_at(i)
				positional_index += 1
			else:
				i += 1

	# this is the leftovers that were not extracted.
	return parsed_opts


func add(op_name, default, desc):
	var new_op = null

	if(options.get_by_name(op_name) != null):
		push_error(str('Option [', op_name, '] already exists.'))
	else:
		new_op = Option.new(op_name, default, desc)
		options.add(new_op)

	return new_op


func add_required(op_name, default, desc):
	var op = add(op_name, default, desc)
	if(op != null):
		op.required = true
	return op


func add_positional(op_name, default, desc):
	var new_op = null
	if(options.get_by_name(op_name) != null):
		push_error(str('Positional option [', op_name, '] already exists.'))
	else:
		new_op = Option.new(op_name, default, desc)
		options.add_positional(new_op)
	return new_op


func add_positional_required(op_name, default, desc):
	var op = add_positional(op_name, default, desc)
	if(op != null):
		op.required = true
	return op


func add_heading(display_text):
	options.add_heading(display_text)


func get_value(name):
	var found_param = options.get_by_name(name)

	if(found_param != null):
		return found_param.value
	else:
		print("COULD NOT FIND OPTION " + name)
		return null


# This will return null instead of the default value if an option has not been
# specified.  This can be useful when providing an order of precedence to your
# values.  For example if
#	default value < config file < command line
# then you do not want to get the default value for a command line option or it
# will overwrite the value in a config file.
func get_value_or_null(name):
	var found_param = options.get_by_name(name)

	if(found_param != null and found_param.has_been_set()):
		return found_param.value
	else:
		return null


func get_help():
	var sep = '---------------------------------------------------------'

	var text = str(sep, "\n", banner, "\n")
	text += options.get_usage_text() + "\n"
	text += "\nOptions\n-------\n"
	text += options.get_help_text()
	text += str(sep, "\n")
	return text


func print_help():
	print(get_help())


func parse(cli_args=OS.get_cmdline_args()):
	unused = _parse_command_line_arguments(cli_args)


func get_missing_required_options():
	return options.get_missing_required_options()


# ##############################################################################
# The MIT License (MIT)
# =====================
#
# Copyright (c) 2024 Tom "Butch" Wesley
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# ##############################################################################