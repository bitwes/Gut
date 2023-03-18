extends Node2D

@onready var _gut_control = $GutControl

func _ready():
	# Returns a gut_config.gd instance.
	var config = _gut_control.get_config()
	
	# Setup all the GUT options from a file.
	config.load_options('res://.gutconfig.json')

	# Override soecific values for the purposes of this
	# scene.  You can see all the options available in
	# the default_options dictionary in gut_config.gd
	config.options.should_exit = false
	config.options.compact_mode = false
	config.options.selected = 'test_test.gd'

	# The gut instance in the GutRunner is not avialable 
	# until after ready (due to some janky psuedo-global-singleton
	# I made and haven't refactored yet, you're welcome).
	call_deferred('_wire_gut')
	
func _wire_gut():
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
