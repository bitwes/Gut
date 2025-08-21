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

@onready var label = $ColorRect/VBox/Label
@onready var btn_kill_it = $ColorRect/VBox/Kill

var _dot_anim = DotsAnimator.new()
var _pipe_results = {}
var _run_time = 0.0


var bottom_panel = null :
	set(val):
		bottom_panel = val
		bottom_panel.resized.connect(_on_bottom_panel_resized)
var blocking_mode = "Blocking"
var additional_arguments = []


func _init():
	_dot_anim.text = "Running"


func _ready():
	btn_kill_it.visible = false


func _process(delta: float) -> void:
	if(_pipe_results != {}):
		if(!OS.is_process_running(_pipe_results.pid)):
			_end_pipe()
		else:
			_update_piped_data(delta)


func _update_piped_data(delta):
	_dot_anim.add_time(delta)
	_run_time += delta
	label.text = _dot_anim.get_animated_text()
	bottom_panel.add_output_text(_pipe_results.stdio.get_as_text())

	var txt_ctrl = bottom_panel.get_text_output_control().get_rich_text_edit()
	txt_ctrl.scroll_vertical = txt_ctrl.get_line_count()


func _end_pipe():
	var txt_ctrl = bottom_panel.get_text_output_control().get_rich_text_edit()
	var last_test_output_line = txt_ctrl.get_line_count()

	bottom_panel.add_output_text(_pipe_results.stderr.get_as_text())
	txt_ctrl.scroll_vertical = last_test_output_line -5
	bottom_panel.load_result_json()

	_pipe_results = {}
	queue_free()


func _run_blocking(options):
	label.text = "When tests finish you can use the editor again."
	btn_kill_it.visible = false
	var output = []
	await get_tree().create_timer(.1).timeout

	OS.execute(OS.get_executable_path(), options, output, true)

	bottom_panel.add_output_text(output[0])
	bottom_panel.load_result_json()
	queue_free()


func _run_non_blocking(options):
	_pipe_results = OS.execute_with_pipe(OS.get_executable_path(), options)
	btn_kill_it.visible = true


func _center_me():
	position = get_parent().size / 2.0 - size / 2.0

# ----------------
# Events
# ----------------
func _on_kill_pressed() -> void:
	if(_pipe_results != {} and OS.is_process_running(_pipe_results.pid)):
		OS.kill(_pipe_results.pid)
		btn_kill_it.visible = false


func _on_color_rect_gui_input(event: InputEvent) -> void:
	if(event is InputEventMouseMotion):
		if(event.button_mask == MOUSE_BUTTON_MASK_LEFT):
			position += event.relative


func _on_bottom_panel_resized():
	_center_me()

# ----------------
# Public
# ----------------
func run_tests():
	_center_me()
	label.visible = true

	var options = ["-s", "res://addons/gut/gut_cmdln.gd", "-graie", "-gdisable_colors",
		"-gconfig", GutEditorGlobals.editor_run_gut_config_path]
	options.append_array(additional_arguments)

	if(blocking_mode == 'Blocking'):
		_run_blocking(options)
	else:
		_run_non_blocking(options)
