extends Panel

onready var _script_list = $ScriptsList
onready var _nav = {
	prev = $Navigation/Previous,
	next = $Navigation/Next,
	run = $Navigation/Run,
	current_script = $Navigation/CurrentScript,
	show_scripts = $Navigation/ShowScripts
}
onready var _progress = {
	script = $ScriptProgress,
	test = $TestProgress
}
onready var _summary = {
	failing = $Summary/Failing,
	passing = $Summary/Passing
}

onready var _extras = $ExtraOptions
onready var _ignore_pauses = $ExtraOptions/IgnorePause
onready var _continue_button = $Continue/Continue
onready var _text_box = $TextDisplay/RichTextLabel

onready var _titlebar = {
	bar = $TitleBar,
	time = $TitleBar/Time,
	label = $TitleBar/Title
}

var _mouse = {
	down = false,
	in_title = false,
	down_pos = null,
	in_handle = false
}
var _is_running = false
var _start_time = 0.0
var _time = 0.0

const DEFAULT_TITLE = 'Gut: The Godot Unit Testing tool.'
var _utils = load('res://addons/gut/utils.gd').new()
var _text_box_blocker_enabled = true
var _pre_maximize_size = null

signal end_pause
signal ignore_pause
signal log_level_changed
signal run_script
signal run_single_script
signal script_selected

func _ready():
	_pre_maximize_size = rect_size
	_hide_scripts()
	_update_controls()
	_nav.current_script.set_text("No scripts available")
	set_title()
	clear_summary()
	$TitleBar/Time.set_text("")
	$ExtraOptions/DisableBlocker.pressed = !_text_box_blocker_enabled
	_extras.visible = false
	update()

func _process(delta):
	if(_is_running):
		_time = OS.get_unix_time() - _start_time
		var disp_time = round(_time * 100)/100
		$TitleBar/Time.set_text(str(disp_time))

func _draw(): # needs get_size()
	# Draw the lines in the corner to show where you can
	# drag to resize the dialog
	var grab_margin = 3
	var line_space = 3
	var grab_line_color = Color(.4, .4, .4)
	for i in range(1, 10):
		var x = rect_size - Vector2(i * line_space, grab_margin)
		var y = rect_size - Vector2(grab_margin, i * line_space)
		draw_line(x, y, grab_line_color, 1, true)

func _on_Maximize_draw():
	# draw the maximize square thing.
	var btn = $TitleBar/Maximize
	btn.set_text('')
	var w = btn.get_size().x
	var h = btn.get_size().y
	btn.draw_rect(Rect2(0, 0, w, h), Color(0, 0, 0, 1))
	btn.draw_rect(Rect2(2, 4, w - 4, h - 6), Color(1,1,1,1))

func _on_ShowExtras_draw():
	var btn = $Continue/ShowExtras
	btn.set_text('')
	var start_x = 20
	var start_y = 15
	var pad = 5
	var color = Color(.1, .1, .1, 1)
	var width = 2
	for i in range(3):
		var y = start_y + pad * i
		btn.draw_line(Vector2(start_x, y), Vector2(btn.get_size().x - start_x, y), color, width, true)

# ####################
# GUI Events
# ####################
func _on_Run_pressed():
	_run_mode()
	emit_signal('run_script', get_selected_index())

func _on_CurrentScript_pressed():
	_run_mode()
	emit_signal('run_single_script', get_selected_index())

func _on_Previous_pressed():
	_select_script(get_selected_index() - 1)

func _on_Next_pressed():
	_select_script(get_selected_index() + 1)

func _on_LogLevelSlider_value_changed(value):
	emit_signal('log_level_changed', $LogLevelSlider.value)

func _on_Continue_pressed():
	_continue_button.disabled = true
	emit_signal('end_pause')

func _on_IgnorePause_pressed():
	var checked = _ignore_pauses.is_pressed()
	emit_signal('ignore_pause', checked)
	if(checked):
		emit_signal('end_pause')
		_continue_button.disabled = true

func _on_ShowScripts_pressed():
	_toggle_scripts()

func _on_ScriptsList_item_selected(index):
	_select_script(index)

func _on_TitleBar_mouse_entered():
	_mouse.in_title = true

func _on_TitleBar_mouse_exited():
	_mouse.in_title = false

func _input(event):
	if(event is InputEventMouseButton):
		if(event.button_index == 1):
			_mouse.down = event.pressed
			if(_mouse.down):
				_mouse.down_pos = event.position

	if(_mouse.in_title):
		if(event is InputEventMouseMotion and _mouse.down):
			set_position(get_position() + (event.position - _mouse.down_pos))
			_mouse.down_pos = event.position

	if(_mouse.in_handle):
		if(event is InputEventMouseMotion and _mouse.down):
			var new_size = rect_size + event.position - _mouse.down_pos
			var new_mouse_down_pos = event.position
			rect_size = new_size
			_mouse.down_pos = new_mouse_down_pos
			_pre_maximize_size = rect_size

func _on_ResizeHandle_mouse_entered():
	_mouse.in_handle = true

func _on_ResizeHandle_mouse_exited():
	_mouse.in_handle = false

# Send scroll type events through to the text box
func _on_FocusBlocker_gui_input(ev):
	if(_text_box_blocker_enabled):
		if(ev is InputEventPanGesture):
			get_text_box()._gui_input(ev)
		# convert a drag into a pan gesture so it scrolls.
		elif(ev is InputEventScreenDrag):
			var converted = InputEventPanGesture.new()
			converted.delta = Vector2(0, ev.relative.y)
			converted.position = Vector2(0, 0)
			get_text_box()._gui_input(converted)
		elif(ev is InputEventMouseButton and (ev.button_index == BUTTON_WHEEL_DOWN or ev.button_index == BUTTON_WHEEL_UP)):
			get_text_box()._gui_input(ev)
	else:
		get_text_box()._gui_input(ev)
		print(ev)

func _on_RichTextLabel_gui_input(ev):
	pass
	# leaving this b/c it is wired up and might have to send
	# more signals through
	print(ev)

func _on_Copy_pressed():
	_text_box.select_all()
	_text_box.copy()
	_text_box.deselect()

func _on_DisableBlocker_toggled(button_pressed):
	_text_box_blocker_enabled = !button_pressed

func _on_ShowExtras_toggled(button_pressed):
	_extras.visible = button_pressed

func _on_Maximize_pressed():
	if(rect_size == _pre_maximize_size):
		maximize()
	else:
		rect_size = _pre_maximize_size
# ####################
# Private
# ####################
func _run_mode(is_running=true):
	if(is_running):
		_start_time = OS.get_unix_time()
		_time = _start_time
		_summary.failing.set_text("0")
		_summary.passing.set_text("0")
	_is_running = is_running

	_hide_scripts()
	var ctrls = $Navigation.get_children()
	for i in range(ctrls.size()):
		ctrls[i].disabled = is_running

func _select_script(index):
	$Navigation/CurrentScript.set_text(_script_list.get_item_text(index))
	_script_list.select(index)
	_update_controls()

func _toggle_scripts():
	if(_script_list.visible):
		_hide_scripts()
	else:
		_show_scripts()

func _show_scripts():
	_script_list.show()

func _hide_scripts():
	_script_list.hide()

func _update_controls():
	var is_empty = _script_list.get_selected_items().size() == 0
	if(is_empty):
		_nav.next.disabled = true
		_nav.prev.disabled = true
	else:
		var index = get_selected_index()
		_nav.prev.disabled = index <= 0
		_nav.next.disabled = index >= _script_list.get_item_count() - 1

	_nav.run.disabled = is_empty
	_nav.current_script.disabled = is_empty
	_nav.show_scripts.disabled = is_empty


# ####################
# Public
# ####################
func run_mode(is_running=true):
	_run_mode(is_running)

func set_scripts(scripts):
	_script_list.clear()
	for i in range(scripts.size()):
		_script_list.add_item(scripts[i])
	_select_script(0)
	_update_controls()

func select_script(index):
	_select_script(index)

func get_selected_index():
	return _script_list.get_selected_items()[0]

func get_log_level():
	return $LogLevelSlider.value

func set_log_level(value):
	$LogLevelSlider.value = _utils.nvl(value, 0)

func set_ignore_pause(should):
	_ignore_pauses.pressed = should

func get_ignore_pause():
	return _ignore_pauses.pressed

func get_text_box():
	return $TextDisplay/RichTextLabel

func end_run():
	_run_mode(false)
	_update_controls()

func set_progress_script_max(value):
	_progress.script.set_max(value)

func set_progress_script_value(value):
	_progress.script.set_value(value)

func set_progress_test_max(value):
	_progress.test.set_max(value)

func set_progress_test_value(value):
	_progress.test.set_value(value)

func clear_progress():
	_progress.test.set_value(0)
	_progress.script.set_value(0)

func pause():
	print('we got here')
	_continue_button.disabled = false

func set_title(title=null):
	if(title == null):
		$TitleBar/Title.set_text(DEFAULT_TITLE)
	else:
		$TitleBar/Title.set_text(title)

func get_run_duration():
	return $TitleBar/Time.text.to_float()

func add_passing(amount=1):
	if(!_summary):
		return
	_summary.passing.set_text(str(_summary.passing.get_text().to_int() + amount))
	$Summary.show()

func add_failing(amount=1):
	if(!_summary):
		return
	_summary.failing.set_text(str(_summary.failing.get_text().to_int() + amount))
	$Summary.show()

func clear_summary():
	_summary.passing.set_text("0")
	_summary.failing.set_text("0")
	$Summary.hide()

func maximize():
	if(is_inside_tree()):
		var vp_size_offset = get_viewport().size
		rect_size = vp_size_offset / get_scale()
		set_position(Vector2(0, 0))

