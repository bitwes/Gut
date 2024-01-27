extends SceneTree

var GutRunner = load('res://addons/gut/gui/GutRunner.tscn')
var GutScene = load('res://addons/gut/GutScene.tscn')
var OrphanCounter = load('res://addons/gut/orphan_counter.gd')
var GutConfig = load('res://addons/gut/gut_config.gd')

var runner = null


func run_gut():
	# _final_opts = opt_resolver.get_resolved_values();
	# _gut_config.options = _final_opts

	runner = GutRunner.instantiate()
	runner.ran_from_editor = false
	get_root().add_child(runner)
	await create_timer(.5).timeout

	var config = GutConfig.new()
	runner.set_gut_config(config)

	var _tester = runner.get_gut()
	_tester.end_run.connect( _on_tests_finished)

	OrphanCounter.sprint_orphans('Before run')
	runner.run_tests()
	# end_it()

func _on_tests_finished():
	end_it.call_deferred()


func end_it():
	runner.free()
	OrphanCounter.sprint_orphans('After run')
	await create_timer(.5).timeout
	quit()


func _whatever():
	# var gs = GutScene.instantiate()
	# get_root().add_child(gs)

	var gr = GutRunner.instantiate()
	gr.ran_from_editor = false
	get_root().add_child(gr)
	get_root().remove_child(gr)
	# gr.kill_scenes()
	gr.free()
	quit()

func wait_a_bit_and_quit():
	await create_timer(.5).timeout
	quit()


func _init():
	run_gut()
