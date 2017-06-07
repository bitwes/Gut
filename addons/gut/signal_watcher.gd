
# Some arbitrary string that should never show up by accident.  If it does, then
# shame on  you.
const ARG_NOT_SET = '_*_argument_*_is_*_not_set_*_'

var _watched_signals = {}

func _add_watched_signal(obj, name):
	if(!_watched_signals.has(obj)):
		_watched_signals[obj] = {name:0}

# This handles all the signals that are watched.  It supports up to 9 parameters
# which could be emitted by the signal and the two parameters used when it is
# connected via watch_signal.  I chose 9 since you can only specify up to 9
# parameters when dynamically calling a method via call (per the Godot
# documentation, i.e. some_object.call('some_method', 1, 2, 3...))
func _on_watched_signal(arg1=ARG_NOT_SET, arg2=ARG_NOT_SET, arg3=ARG_NOT_SET, \
                        arg4=ARG_NOT_SET, arg5=ARG_NOT_SET, arg6=ARG_NOT_SET, \
						arg7=ARG_NOT_SET, arg8=ARG_NOT_SET, arg9=ARG_NOT_SET, \
						arg10=ARG_NOT_SET, arg11=ARG_NOT_SET):
	var args = [arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11]
	var idx = args.size() -1
	while(str(args[idx]) == ARG_NOT_SET):
		args.remove(idx)
		idx -= 1
	_handle_watched_signal(args)


# Accepts an array of arguments where the last two are the parameters passed
# when we connect to the signal (signal name and a reference to the object.)
func _handle_watched_signal(args=[]):
	var signal_name = args[args.size() -1]
	var object = args[args.size() -2]
	_watched_signals[object][signal_name] += 1

func watch_signal(object, signal_name):
	if(object.has_user_signal(signal_name)):
		_add_watched_signal(object, signal_name)
		object.connect(signal_name, self, '_on_watched_signal', [object, signal_name])

func get_emit_count(object, signal_name):
	return _watched_signals[object][signal_name]

func did_emit(object, signal_name):
	return _watched_signals[object][signal_name] != 0

func print_signals(object):
	var list = object.get_signal_list()
	#print(list)
	for i in range(list.size()):
		print(list[i].name, "\n  ", list[i])
