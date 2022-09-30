extends Node

signal pause_ended
signal pause_started

var _pause_time = 0.0
var _pause_frames = 0
var _pause_until_signal = null

var _elapsed_time = 0.0
var _elapsed_frames = 0

func _physics_process(delta):
    if(_pause_time != 0.0):
        _elapsed_time += delta
        if(_elapsed_time >= _pause_time):
            _end_pause()

    if(_pause_frames != 0):
        _elapsed_frames += 1
        if(_elapsed_frames >= _pause_frames):
            _end_pause()

func _end_pause():
    _pause_time = 0.0
    _pause_frames = 0
    _pause_until_signal = null
    _elapsed_time = 0.0
    _elapsed_frames = 0
    pause_ended.emit()

func _signal_callback():
    _pause_until_signal.disconnect(_signal_callback)
    _end_pause()

func pause_for(x):
    _pause_time = x
    pause_started.emit()

func pause_frames(x):
    _pause_frames = x
    pause_started.emit()

func pause_until(the_signal, x):
    the_signal.connect(_signal_callback)
    _pause_until_signal = the_signal
    _pause_time = x
    pause_started.emit()

func is_paused():
    return _pause_time != 0.0 || _pause_frames != 0

