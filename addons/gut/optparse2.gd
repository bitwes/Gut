#-------------------------------------------------------------------------------
# Simple class to hold a command line option
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

	func _init(name,default_value,desc=''):
		option_name = name
		default = default_value
		description = desc
		value = empty_value#default_value

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
# The high level interface between this script and the command line options
# supplied.  Uses Option class and CmdLineParser to extract information from
# the command line and make it easily accessible.
#-------------------------------------------------------------------------------
var options = []
var positional = []
var banner = ''
var option_name_prefix = '-'


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


func _find_option_by_name(opt_name):
	var idx = 0
	var found_param = null
	while(idx < options.size() and found_param == null):
		if(options[idx].option_name == opt_name):
			found_param = options[idx]
		else:
			idx += 1
	return found_param


func _parse_command_line_arguments(args):
	var parsed_opts = args.duplicate()
	var i = 0
	var positional_index = 0

	while i < parsed_opts.size():
		var opt  = ''
		var value = ''
		var entry = parsed_opts[i]

		if(_is_option(entry)):
			parsed_opts.remove_at(i)

			if(entry.find('=') != -1):
				var parts = entry.split('=')
				opt = parts[0]
				value = parts[1]
				var the_option = _find_option_by_name(opt)
				if(the_option != null):
					_set_option_value(the_option, value)
			else:
				var the_option = _find_option_by_name(entry)
				if(the_option != null):
					if(typeof(the_option.default) == TYPE_BOOL):
						_set_option_value(the_option, null)
					elif(i < parsed_opts.size() and !_is_option(parsed_opts[i])):
						value = parsed_opts[i]
						parsed_opts.remove_at(i)
						_set_option_value(the_option, value)
		else:
			if(positional_index < positional.size()):
				_set_option_value(positional[positional_index], entry)
				parsed_opts.remove_at(i)
				positional_index += 1
			else:
				i += 1

	return parsed_opts


func add(op_name, default, desc):
	options.append(Option.new(op_name, default, desc))


func add_positional(op_name, default, desc):
	positional.append(Option.new(op_name, default, desc))


func get_value(name):
	var idx = 0
	var found_param = null

	while(idx < options.size() and found_param == null):
		if(options[idx].option_name == name):
			found_param = options[idx]
		else:
			idx += 1

	if(found_param == null):
		idx = 0
		while(idx < positional.size() and found_param == null):
			if(positional[idx].option_name == name):
				found_param = positional[idx]
			else:
				idx += 1

	if(found_param != null):
		return found_param.value
	else:
		print("COULD NOT FIND OPTION " + name)
		return null


func get_help():
	var longest = 0
	for i in range(options.size()):
		if(options[i].option_name.length() > longest):
			longest = options[i].option_name.length()
	var sep = '---------------------------------------------------------'

	var text = str(sep, "\n", banner, "\n")
	text += "\nOptions\n-------\n"
	for i in range(options.size()):
		text += str('  ', options[i].to_s(longest + 2), "\n")
	text += str(sep, "\n")
	return text


func print_help():
	print(get_help())


func print_options():
	for i in range(options.size()):
		print(options[i].option_name + '=' + str(options[i].value))


func parse(cli_args=OS.get_cmdline_args()):
	var unused = _parse_command_line_arguments(cli_args)

	if(unused.size() > 0):
		print("Unrecognized options:  ", unused)
		return false

	return true


































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