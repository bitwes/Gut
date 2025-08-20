@tool
extends Control

class DotsAnimator:
	var text = ''
	var dot = '.'
	var max_dots = 3
	var dot_delay = .5
	
	var _anim_text = ''
	var _elapsed_time = 0.0
	var _cur_dots = 0
	
	func get_animated_text():
		return _anim_text
		
	func add_time(delta):
		_elapsed_time += delta
		if(_elapsed_time > dot_delay):
			_elapsed_time = 0
			_cur_dots += 1
			if(_cur_dots > max_dots):
				_cur_dots = 0
			
			_anim_text = text.rpad(text.length() + _cur_dots, dot)
		

var GutEditorGlobals = load('res://addons/gut/gui/editor_globals.gd')

@onready var btn_free = $ColorRect/Free
@onready var btn_do_it = $ColorRect/DoIt
@onready var label = $ColorRect/VBox/Label
@onready var btn_kill_it = $ColorRect/VBox/Kill

var _dot_anim = DotsAnimator.new()
var _pipe_results = {}
var _bottom_panel = null

var blocking_mode = "Blocking"
var additional_arguments = []

func _init(bottom_panel=null):
	_bottom_panel = bottom_panel
	_dot_anim.text = "Running"
	
func _ready():
	btn_kill_it.visible = false
	btn_free.visible = false
	btn_do_it.visible = false

func _on_free_pressed() -> void:
	queue_free()


var _run_time = 0.0
func _process(delta: float) -> void:
	if(_pipe_results != {}):
		if(!OS.is_process_running(_pipe_results.pid)):
			_end_pipe()
		else:
			_dot_anim.add_time(delta)
			_run_time += delta
			label.text = _dot_anim.get_animated_text()
			#_bottom_panel._ctrls.output_ctrl.clear()
			var txt_ctrl = _bottom_panel._ctrls.output_ctrl
			txt_ctrl.add_text(_pipe_results.stdio.get_as_text())
			txt_ctrl._ctrls.output.scroll_vertical = txt_ctrl._ctrls.output.get_line_count()


func _end_pipe():
	#_pipe_results.stdio.seek(0)
	var txt_ctrl = _bottom_panel._ctrls.output_ctrl
	var last_test_line = txt_ctrl._ctrls.output.get_line_count()
	txt_ctrl.add_text(_pipe_results.stderr.get_as_text())
	txt_ctrl._ctrls.output.scroll_vertical = last_test_line -5
	#var text =  + _pipe_results.stdio.get_as_text()
	#_bottom_panel.write_file(GutEditorGlobals.editor_run_bbcode_results_path, text)
	#_bottom_panel.load_result_output()
	_bottom_panel.load_result_json()
	
	_pipe_results = {}
	queue_free()


func _do_it_blocking(options):
	label.text = "When tests finish you can use the editor again."
	btn_kill_it.visible = false
	var output = []
	await get_tree().create_timer(.1).timeout
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

func _center_me():
	position = get_parent().size / 2.0 - size / 2.0
	

func run_tests():	
	_center_me()
	btn_free.visible = false
	btn_do_it.visible = false
	label.visible = true
	#self.queue_redraw()
	#await get_tree().create_timer(.1).timeout
	var options = ["-s", "res://addons/gut/gut_cmdln.gd", "-graie", "-gdisable_colors",
		"-gconfig", GutEditorGlobals.editor_run_gut_config_path]
	options.append_array(additional_arguments)
	
	if(blocking_mode == 'Blocking'):
		_do_it_blocking(options)
	else:
		_do_it_pipe(options)
