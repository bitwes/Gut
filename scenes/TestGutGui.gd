extends Node2D

class SignalReporter:
	extends 'res://addons/gut/signal_watcher.gd'


	func _on_watched_signal(arg1=ARG_NOT_SET, arg2=ARG_NOT_SET, arg3=ARG_NOT_SET, \
							arg4=ARG_NOT_SET, arg5=ARG_NOT_SET, arg6=ARG_NOT_SET, \
							arg7=ARG_NOT_SET, arg8=ARG_NOT_SET, arg9=ARG_NOT_SET, \
							arg10=ARG_NOT_SET, arg11=ARG_NOT_SET):
		var args = [arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11]

		# strip off any unused vars.
		var idx = args.size() -1
		while(str(args[idx]) == ARG_NOT_SET):
			args.remove_at(idx)
			idx -= 1
		var signal_name = args[args.size() -1]
		args.pop_back()



		super._on_watched_signal(arg1, arg2, arg3, \
			arg4,  arg5, arg6, \
			arg7,  arg8, arg9, \
			arg10, arg11)

var signal_reporter = SignalReporter.new()

func _ready():
	signal_reporter.watch_signals($Gut)
	_add_bunch_of_scripts(30)



func _add_bunch_of_scripts(how_many):
	var scripts = []
	for i in range(how_many):
		scripts.append(str('res://test/unit/integration/unit/test_script_that_tests_something', i, '.gd'))
	$Gut.set_scripts(scripts)



func _on_EndRunMode_pressed():
	$Gut.end_run()


func _on_PauseBeforeTeardown_pressed():
	$Gut.pause()


func _on_Fail_pressed():
	$Gut.add_failing()


func _on_Pass_pressed():
	$Gut.add_passing()


func _on_Clear_Summary_pressed():
	$Gut.clear_summary()
