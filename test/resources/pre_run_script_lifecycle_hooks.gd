extends GutHookScript

const NO_TEST := "__NO_TEST__"
var _current_test_script_object = null
var _current_collected_script = null
var _current_test_name := NO_TEST
var _event_log: Array[String] = []

func run():
	gut.start_run.connect(_on_run_started)
	gut.start_script.connect(_on_script_started)
	gut.start_test.connect(_on_test_started)
	gut.end_test.connect(_on_test_ended)
	gut.end_script.connect(_on_script_ended)
	gut.end_run.connect(_on_run_ended)
	
	gut.set_meta("pre_run_script_lifecycle_hooks_data", _event_log)

	# Do pre-run stuff here

# This might be redundant, and it might have already been emitted by the time
# this hook is called.  I wanted it in here for illustration purposes.
func _on_run_started():
	_event_log.push_back("test run started")

# This is passed an instance of res://addons/gut/collected_script.gd.  It is not
# the instance of the script that will be run.  You can get to the script object
# using `load_script`, but you can't get to the actual instance that will be
# run.
func _on_script_started(collected_script):
	_current_collected_script = collected_script
	# The GutTest script, not the instance.
	_current_test_script_object = collected_script.load_script()
	_event_log.push_back(_current_collected_script.get_full_name() + " loaded from collected script")


# This is just the name of the test method being ran.
func _on_test_started(test_name):
	_current_test_name = test_name
	_event_log.push_back("starting test " + _current_test_name)


func _on_test_ended():
	# example of inspecing the test that ended if you wanted to.
	var failed = _current_collected_script.get_test_named(_current_test_name).is_failing()
	if (failed):
		_event_log.push_back(_current_test_name + " failed")
	else:
		_event_log.push_back(_current_test_name + " passed")

	_current_test_name = NO_TEST


func _on_script_ended():
	#example of inspecing the script that ended if you wanted to
	if(!_current_collected_script.was_skipped):
		if(_current_collected_script.get_fail_count() > 0):
			print("The script ", _current_collected_script.get_full_name(), " failed.")
			_event_log.push_back(_current_collected_script.get_full_name() + " failed")
		else:
			print("cool.")
			_event_log.push_back(_current_collected_script.get_full_name() + " passed")
			
	_current_collected_script = null
	_current_test_script_object = null


# I'm not sure if this is called before or after the post-run hook.  This can't
# do everything a post-run hook can do, but it might be enough for this.
func _on_run_ended():
	_event_log.push_back("test run ended")
	# Do "after_every" things here.
