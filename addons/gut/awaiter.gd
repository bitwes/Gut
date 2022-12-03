extends Node

signal timeout
signal wait_started

var _pause_time = 0.0
var _pause_frames = 0
var _pause_until_signal = null

var _elapsed_time = 0.0
var _elapsed_frames = 0

func _physics_process(delta):
	if(_pause_time != 0.0):
		_elapsed_time += delta
		if(_elapsed_time >= _pause_time):
			_end_wait()

	if(_pause_frames != 0):
		_elapsed_frames += 1
		if(_elapsed_frames >= _pause_frames):
			_end_wait()

func _end_wait():
	_pause_time = 0.0
	_pause_frames = 0
	_pause_until_signal = null
	_elapsed_time = 0.0
	_elapsed_frames = 0
	timeout.emit()

const ARG_NOT_SET = '_*_argument_*_is_*_not_set_*_'
func _signal_callback(arg1=ARG_NOT_SET, arg2=ARG_NOT_SET, arg3=ARG_NOT_SET,
	arg4=ARG_NOT_SET, arg5=ARG_NOT_SET, arg6=ARG_NOT_SET,
	arg7=ARG_NOT_SET, arg8=ARG_NOT_SET, arg9=ARG_NOT_SET,
	arg10=ARG_NOT_SET, arg11=ARG_NOT_SET):

	var args = [arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11]

	# strip off any unused vars.
	var idx = args.size() -1
	while(str(args[idx]) == ARG_NOT_SET):
		args.remove_at(idx)
		idx -= 1

	# retrieve object and signal name from the array and remove_at them.  These
	# will always be at the end since they are added when the connect happens.
	var source_signal = args[args.size() -1]
	args.pop_back()

	source_signal.disconnect(_signal_callback)

	# DO NOT _end_wait here.  For other parts of the test to get the signal that
	# was waited on, we have to wait for a couple more frames.  For example, the
	# signal_watcher doesn't get the signal in time if we don't do this.
	_pause_frames = 2


func wait_for(x):
	_pause_time = x
	wait_started.emit()

func wait_frames(x):
	_pause_frames = x
	wait_started.emit()

func wait_for_signal(the_signal, x):
	var callback = _signal_callback.bind(the_signal)
	the_signal.connect(callback)
	_pause_until_signal = the_signal
	_pause_time = x
	wait_started.emit()

func is_waiting():
	return _pause_time != 0.0 || _pause_frames != 0

