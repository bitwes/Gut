extends GutTest

var SignalWatcher = load('res://addons/gut/signal_watcher.gd')

class SignalObject:
	extends Node2D

	signal no_parameters
	signal one_parameter(someting)
	signal two_parameters(num, letters)
	signal some_signal


var gr = {
	so = null,
	sw = null
}

func before_each():
	gr.sw = SignalWatcher.new()
	gr.so = autofree(SignalObject.new())

func after_each():
	gr.sw = null
	gr.so = null

func test_did_emit_with_signal():
	gr.sw.watch_signals(gr.so)
	gr.so.no_parameters.emit()
	assert_true(gr.sw.did_emit(gr.so.no_parameters))
