extends Node2D
const RUNNER_JSON_PATH = 'res://.gut_editor_config.json'
@onready var _gut_control = $GutControl

func _ready():
	# Load the Gut Panel settings file.  This can be any
	# gutconfig file.  Must call load_panel_options instead
	# of load_options since we are using the panel's settings
	# control.
	#
	# Settings are not saved, so any changes will be lost.
	# The idea is that you want to deploy the settings and 
	# users should not be able to save them.
	_gut_control.load_config_file(RUNNER_JSON_PATH)

	# Returns a gut_config.gd instance.
	var config = _gut_control.get_config()

	# Override soecific values for the purposes of this
	# scene.  You can see all the options available in
	# the default_options dictionary in gut_config.gd
	config.options.should_exit = false
	config.options.compact_mode = false

	call_deferred('_post_ready_setup')


# The control must be refreshed after _ready for all the tests
# to populate, and the settings to populate.  This is due to 
# some timing issues with gut.gd.
#
# This is also where you would connect to any signals provided by
# the gut.gd instance held in the GutRunner.
func _post_ready_setup():
	# This method will populate the tree and also the settings
	# panel.  This cannot be called until _ready has finished.
	_gut_control.refresh()
	
	# Get a reference to the gut.gd instance that is used to
	# run tests, and then connect to some signals for demo 
	# purposes.
	var gut = _gut_control.get_gut()
	gut.start_run.connect(_on_gut_run_start)
	gut.start_script.connect(_on_gut_start_script)
	gut.start_test.connect(_on_gut_test_started)
	gut.end_run.connect(_on_gut_run_end)


func _on_gut_run_start():
	print('Starting tests')


# This signal passes a TestCollector.gd/TestScript instance
func _on_gut_start_script(script_obj):
	print(script_obj.get_full_name(), ' has ', script_obj.tests.size(), ' tests')


func _on_gut_test_started(test_name):
	print('  ', test_name)


func _on_gut_run_end():
	print('Tests Done')
#
