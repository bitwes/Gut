@tool
extends Node2D
var GutEditorGlobals = load('res://addons/gut/gui/editor_globals.gd')

@onready var btn_free = $ColorRect/Free
@onready var btn_do_it = $ColorRect/DoIt
@onready var label = $ColorRect/Label
@onready var btn_kill_it = $ColorRect/Kill

var _pipe_results = {}
var _bottom_panel = null

var blocking_mode = "Blocking"
var additional_arguments = []

func _init(bottom_panel=null):
	_bottom_panel = bottom_panel
	

func _on_free_pressed() -> void:
	queue_free()


var _run_time = 0.0
func _process(delta: float) -> void:
	if(_pipe_results != {}):
		if(!OS.is_process_running(_pipe_results.pid)):
			_end_pipe()
		else:
			_run_time += delta
			label.text = str(_run_time)


func _end_pipe():
	var text = _pipe_results.stderr.get_as_text() + _pipe_results.stdio.get_as_text()
	_bottom_panel.write_file(GutEditorGlobals.editor_run_bbcode_results_path, text)
	_bottom_panel.load_result_output()
	
	_pipe_results = {}
	queue_free()


func _do_it_blocking(options):
	var output = []
	OS.execute(OS.get_executable_path(), options, output, true)
	
	_bottom_panel.write_file(GutEditorGlobals.editor_run_bbcode_results_path, output[0])
	_bottom_panel.load_result_output()
	queue_free()


func _do_it_pipe(options):
	_pipe_results = OS.execute_with_pipe(OS.get_executable_path(), options)
	btn_kill_it.visible = true
	
	
func _on_do_it_pressed() -> void:
	run_tests()	
	
	
func _on_kill_pressed() -> void:
	if(_pipe_results != {} and OS.is_process_running(_pipe_results.pid)):
		OS.kill(_pipe_results.pid)
		btn_kill_it.visible = false


func run_tests():	
	btn_free.visible = false
	btn_do_it.visible = false
	label.visible = true
	self.queue_redraw()
	await get_tree().create_timer(.1).timeout
	var options = ["-s", "res://addons/gut/gut_cmdln.gd", "-graie", "-gdisable_colors",
		"-gconfig", GutEditorGlobals.editor_run_gut_config_path]
	options.append_array(additional_arguments)
	
	if(blocking_mode == 'Blocking'):
		_do_it_blocking(options)
	else:
		_do_it_pipe(options)
