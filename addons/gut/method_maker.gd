class CallParameters:
	var p_name = null
	var default = null
	var vararg = false

	func _init(n,d):
		p_name = n
		default = d

	func get_signature():
		if(vararg):
			return "...args: Array"
		else:
			return str(p_name, "=", default)




# ------------------------------------------------------------------------------
# This class will generate method declaration lines based on method meta
# data.  It will create defaults that match the method data.
#
# --------------------
# function meta data
# --------------------
# name:
# flags:
# args: [{
# 	(class_name:),
# 	(hint:0),
# 	(hint_string:),
# 	(name:),
# 	(type:4),
# 	(usage:7)
# }]
# default_args []
const PARAM_PREFIX = 'p_'


var _lgr = GutUtils.get_logger()
static var _func_template = GutUtils.get_file_as_text('res://addons/gut/double_templates/function_template.txt')
static var _init_template = GutUtils.get_file_as_text('res://addons/gut/double_templates/init_template.txt')


# ###############
# Private
# ###############

func _make_stub_default(method, index):
	return str('__gutdbl.default_val("', method, '",', index, ')')


func _make_arg_array(method_meta):
	var to_return = []

	for i in range(method_meta.args.size()):
		var pname = method_meta.args[i].name
		var dflt_text = _make_stub_default(method_meta.name, i)
		to_return.append(CallParameters.new(PARAM_PREFIX + pname, dflt_text))

	if(method_meta.flags & METHOD_FLAG_VARARG):
		var cp = CallParameters.new("args", "")
		cp.vararg = true
		to_return.append(cp)

	return to_return


# Creates a list of parameters with defaults of null unless a default value is
# found in the metadata.  If a default is found in the meta then it is used if
# it is one we know how support.
#
# If a default is found that we don't know how to handle then this method will
# return null.
func _get_arg_text(arg_array):
	var text = ''

	for i in range(arg_array.size()):
		text += arg_array[i].get_signature()
		if(i != arg_array.size() -1):
			text += ', '

	return text


# creates a call to the function in meta in the super's class.
func _get_super_call_text(parsed_method, singleton):
	var return_it = ''
	if(parsed_method.return_type_text != 'void'):
		return_it = 'return '

	if parsed_method.meta.flags & MethodFlags.METHOD_FLAG_VIRTUAL_REQUIRED != 0:
		if(return_it != ''):
			return_it = '; return null'
		return '__gutdbl.gut_ref.get_ref().get_logger().error(' + \
			'"Cannot call super() because method %s is abstract.")%s' \
			% [parsed_method.meta.name, return_it]

	var params = ''
	for i in range(parsed_method.args.size()):
		params += PARAM_PREFIX + parsed_method.args[i].name
		if(i != parsed_method.args.size() -1):
			params += ', '

	if(singleton != null):
		return str(return_it, 'await __gutdbl.get_singleton().', parsed_method.meta.name, '(', params, ')')
	else:
		return str(return_it, 'await super(', params, ')')


func _get_spy_call_parameters_text(args):
	var called_with = 'null'

	if(args.size() > 0):
		called_with = '['
		for i in range(args.size()):
			called_with += args[i].p_name
			if(i < args.size() - 1):
				called_with += ', '
		called_with += ']'

	return called_with


func _get_init_text(meta, args, method_params, param_array):
	var text = null

	var decleration = str('func ', meta.name, '(', method_params, ')')
	var super_params = ''
	if(args.size() > 0):
		for i in range(args.size()):
			super_params += args[i].p_name
			if(i != args.size() -1):
				super_params += ', '

	text = _init_template.format({
		"func_decleration":decleration,
		"super_params":super_params,
		"param_array":param_array,
		"method_name":meta.name,
	})

	return text

# ###############
# Public
# ###############



# Creates a delceration for a function based off of function metadata.  All
# types whose defaults are supported will have their values.  If a datatype
# is not supported and the parameter has a default, a warning message will be
# printed and the declaration will return null.
func get_function_text(parsed_method, singleton=null):
	var meta = parsed_method.meta
	var text = null
	var args = _make_arg_array(meta)
	var param_array = _get_spy_call_parameters_text(args)
	var method_params = _get_arg_text(args);

	if(param_array == 'null'):
		param_array = '[]'

	if(method_params != null):
		if(meta.name == '_init'):
			text =  _get_init_text(meta, args, method_params, param_array)
		else:
			var return_it = ''
			if(parsed_method.return_type_text != 'void'):
				return_it = 'return '

			var decleration = str('func ', meta.name, '(', method_params, '):')
			text = _func_template.format({
				"func_decleration": decleration,
				"method_name": meta.name,
				"param_array": param_array,
				# "super_call": _get_super_call_text(meta, args, singleton),
				"super_call": _get_super_call_text(parsed_method, singleton),
				"return_it": return_it
			})

	return text


func get_logger():
	return _lgr


func set_logger(logger):
	_lgr = logger


