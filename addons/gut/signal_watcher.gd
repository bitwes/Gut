
# Some arbitrary string that should never show up by accident.  If it does, then
# shame on  you.
const ARG_NOT_SET = '_*_argument_*_is_*_not_set_*_'

var _watched_signals = {}

func _add_watched_signal(obj, name):
	if(!_watched_signals.has(obj)):
		_watched_signals[obj] = {name:{'count':0, 'args':[]}}
	else:
		_watched_signals[obj][name] = {'count':0, 'args':[]}

# This handles all the signals that are watched.  It supports up to 9 parameters
# which could be emitted by the signal and the two parameters used when it is
# connected via watch_signal.  I chose 9 since you can only specify up to 9
# parameters when dynamically calling a method via call (per the Godot
# documentation, i.e. some_object.call('some_method', 1, 2, 3...)).
#
# Based on the documentation of emit_signal, it appears you can only pass up
# to 4 parameters when firing a signal.  I haven't verified this, but this should
# future proof this some if the value ever grows.
func _on_watched_signal(arg1=ARG_NOT_SET, arg2=ARG_NOT_SET, arg3=ARG_NOT_SET, \
                        arg4=ARG_NOT_SET, arg5=ARG_NOT_SET, arg6=ARG_NOT_SET, \
						arg7=ARG_NOT_SET, arg8=ARG_NOT_SET, arg9=ARG_NOT_SET, \
						arg10=ARG_NOT_SET, arg11=ARG_NOT_SET):
	var args = [arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11]

	# strip off any unused vars.
	var idx = args.size() -1
	while(str(args[idx]) == ARG_NOT_SET):
		args.remove(idx)
		idx -= 1

	# retrieve object and signal name from the array and remove them.  These
	# will always be at the end since they are added when the connect happens.
	var signal_name = args[args.size() -1]
	args.pop_back()
	var object = args[args.size() -1]
	args.pop_back()

	_watched_signals[object][signal_name]['count'] += 1
	_watched_signals[object][signal_name]['args'].append(args)

func watch_signals(object):
	var signals = object.get_signal_list()
	for i in range(signals.size()):
		watch_signal(object, signals[i]['name'])

func watch_signal(object, signal_name):
	var did = false
	if(object.has_user_signal(signal_name)):
		_add_watched_signal(object, signal_name)
		object.connect(signal_name, self, '_on_watched_signal', [object, signal_name])
		did = true
	return did

func get_emit_count(object, signal_name):
	var to_return = -1
	if(is_watching(object, signal_name)):
		to_return = _watched_signals[object][signal_name]['count']
	return to_return

func did_emit(object, signal_name):
	var did = false
	if(is_watching(object, signal_name)):
		did = get_emit_count(object, signal_name) != 0
	return did

func print_object_signals(object):
	var list = object.get_signal_list()
	for i in range(list.size()):
		print(list[i].name, "\n  ", list[i])

func get_signal_parameters(object, signal_name, index=-1):
	var params = null
	if(is_watching(object, signal_name)):
		var all_params = _watched_signals[object][signal_name]['args']
		if(all_params.size() > 0):
			if(index == -1):
				index = all_params.size() -1
			params = all_params[index]
	return params

func is_watching(object, signal_name):
	return _watched_signals.has(object) and _watched_signals[object].has(signal_name)
