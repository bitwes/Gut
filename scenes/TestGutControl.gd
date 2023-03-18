extends Node2D
@onready var _gut_control = $GutControl

func _ready():
	# You must load a gut config file to use this
	# control.
	#
	# Here we use the Gut Panel settings file.  This can be any
	# gutconfig file, but this one is most likely to exist.
	# You can create your own just for deployed settings.
	#
	# Settings are not saved, so any changes will be lost.
	# The idea is that you want to deploy the settings and 
	# users should not be able to save them.
	_gut_control.load_config_file('res://.gut_editor_config.json')

	# Returns a gut_config.gd instance.
	var config = _gut_control.get_config()
	# Override soecific values for the purposes of this
	# scene.  You can see all the options available in
	# the default_options dictionary in gut_config.gd
	config.options.should_exit = false
	config.options.compact_mode = false

	call_deferred('_post_ready_setup')

# If you would like to connect to signals provided by gut.gd
# then you must do so after _ready.  This is an example of
# getting a reference to gut and some of the signals it 
# provieds.
func _post_ready_setup():
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
