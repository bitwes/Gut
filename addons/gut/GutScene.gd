extends Control

onready var _script_list = $Window/BottomBar/Navigation/CurrentScript/ScriptsList
onready var _log_level_slider = $Window/BottomBar/Indicators/LogLevel/LogLevelSlider
onready var _nav = {
	prev = $Window/BottomBar/Navigation/Controls/Previous,
	next = $Window/BottomBar/Navigation/Controls/Next,
	run = $Window/BottomBar/Navigation/Controls/Run,
	current_script = $Window/BottomBar/Navigation/CurrentScript,
	run_single = $Window/BottomBar/Navigation/Controls/RunSingleScript
}
onready var _progress = {
	script = $Window/BottomBar/Indicators/Scripts/ScriptProgress,
	script_xy = $Window/BottomBar/Indicators/Scripts/ScriptProgress/xy,
	test = $Window/BottomBar/Indicators/Tests/TestProgress,
	test_xy = $Window/BottomBar/Indicators/Tests/TestProgress/xy
}
onready var _summary = {
	failing = $Window/TitleBar/Summary/Failing,
	passing = $Window/TitleBar/Summary/Passing,
	fail_count = 0,
	pass_count = 0
}

onready var _extras = $Window/BottomBar/Continue/ShowExtras/ExtraOptions
onready var _ignore_pauses = $Window/BottomBar/Continue/ShowExtras/ExtraOptions/VBoxContainer/IgnorePause
onready var _continue_button = $Window/BottomBar/Continue/Continue
onready var _text_box = $Window/TextDisplay/RichTextLabel

onready var _titlebar = {
	time = $Window/TitleBar/Time,
	label = $Window/TitleBar/Title
}

onready var _user_files = $UserFileViewer

var _is_running = false
var _start_time = 0.0
var _time = 0.0

const DEFAULT_TITLE = 'Gut: The Godot Unit Testing tool.'
var _pre_maximize_rect = null
var _font_size = 20

signal end_pause
signal ignore_pause
signal log_level_changed
signal run_script
signal run_single_script

func _ready():

	if(Engine.editor_hint):
		return

	_pre_maximize_rect = get_rect()
	_hide_scripts()
	_update_controls()
	_nav.current_script.set_text("No scripts available")
	set_title()
	clear_summary()
	_titlebar.time.set_text("Time 0.0")

	_extras.visible = false
	update()

	set_font_size(_font_size)
	set_font('CourierPrime')

	_user_files.set_position(Vector2(10, 30))

func elapsed_time_as_str():
	return str("%.1f" % (_time / 1000.0), 's')

func _process(_delta):
	if(_is_running):
		_time = OS.get_ticks_msec() - _start_time
		_titlebar.time.set_text(str('Time: ', elapsed_time_as_str()))

# ####################
# GUI Events
# ####################
func _on_Run_pressed():
	_run_mode()
	emit_signal('run_script', get_selected_index())

func _on_CurrentScript_pressed():
	_toggle_scripts()

func _on_Previous_pressed():
	_select_script(get_selected_index() - 1)

func _on_Next_pressed():
	_select_script(get_selected_index() + 1)

func _on_LogLevelSlider_value_changed(_value):
	emit_signal('log_level_changed', _log_level_slider.value)

func _on_Continue_pressed():
	_continue_button.disabled = true
	emit_signal('end_pause')

func _on_IgnorePause_pressed():
	var checked = _ignore_pauses.is_pressed()
	emit_signal('ignore_pause', checked)
	if(checked):
		emit_signal('end_pause')
		_continue_button.disabled = true

func _on_RunSingleScript_pressed():
	_run_mode()
	emit_signal('run_single_script', get_selected_index())

func _on_ScriptsList_item_selected(index):
	var tmr = $Window/BottomBar/Navigation/CurrentScript/ScriptsList/DoubleClickTimer
	if(!tmr.is_stopped()):
		_run_mode()
		emit_signal('run_single_script', get_selected_index())
		tmr.stop()
	else:
		tmr.start()

	_select_script(index)

func _on_RichTextLabel_gui_input(ev):
	pass
	# leaving this b/c it is wired up and might have to send
	# more signals through

func _on_Copy_pressed():
	OS.clipboard = _text_box.text

func _on_ShowExtras_toggled(button_pressed):
	_extras.visible = button_pressed

# ####################
# Private
# ####################
func _run_mode(is_running=true):
	if(is_running):
		_start_time = OS.get_ticks_msec()
		_time = 0.0
		clear_summary()
	_is_running = is_running

	_hide_scripts()
	$Window/BottomBar/Navigation/CurrentScript.disabled = is_running
	var ctrls = $Window/BottomBar/Navigation/Controls.get_children()
	for i in range(ctrls.size()):
		ctrls[i].disabled = is_running

func _select_script(index):
	var text = _script_list.get_item_text(index)
	var max_len = 50
	if(text.length() > max_len):
		text = '...' + text.right(text.length() - (max_len - 5))
	$Window/BottomBar/Navigation/CurrentScript.set_text(text)
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
	_nav.run_single.disabled = is_empty

func _update_summary():
	if(!_summary):
		return

	var total = _summary.fail_count + _summary.pass_count
	$Window/TitleBar/Summary.visible = !total == 0
	$Window/TitleBar/Summary/AssertCount.text = str('Failures ', _summary.fail_count, '/', total)
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
	return _log_level_slider.value

func set_log_level(value):
	var new_value = value
	if(new_value == null):
		new_value = 0
	if _log_level_slider:
		_log_level_slider.value = new_value

func set_ignore_pause(should):
	_ignore_pauses.pressed = should

func get_ignore_pause():
	return _ignore_pauses.pressed

func get_text_box():
	# due to some timing issue, this cannot return _text_box but can return
	# this.
	return $Window/TextDisplay/RichTextLabel

func end_run():
	_run_mode(false)
	_update_controls()

func set_progress_script_max(value):
	var max_val = max(value, 1)
	_progress.script.set_max(max_val)
	_progress.script_xy.set_text(str('0/', max_val))

func set_progress_script_value(value):
	_progress.script.set_value(value)
	var txt = str(value, '/', _progress.test.get_max())
	_progress.script_xy.set_text(txt)

func set_progress_test_max(value):
	var max_val = max(value, 1)
	_progress.test.set_max(max_val)
	_progress.test_xy.set_text(str('0/', max_val))

func set_progress_test_value(value):
	_progress.test.set_value(value)
	var txt = str(value, '/', _progress.test.get_max())
	_progress.test_xy.set_text(txt)

func clear_progress():
	_progress.test.set_value(0)
	_progress.script.set_value(0)

func pause():
	_continue_button.disabled = false

func set_title(title=null):
	if(title == null):
		_titlebar.label.set_text(DEFAULT_TITLE)
	else:
		_titlebar.label.set_text(title)

func add_passing(amount=1):
	if(!_summary):
		return
	_summary.pass_count += amount
	_update_summary()

func add_failing(amount=1):
	if(!_summary):
		return
	_summary.fail_count += amount
	_update_summary()

func clear_summary():
	_summary.fail_count = 0
	_summary.pass_count = 0
	_update_summary()

func maximize():
	if(is_inside_tree()):
		var vp_size_offset = get_viewport().size
		rect_size = vp_size_offset / get_scale()
		set_position(Vector2(0, 0))

func clear_text():
	_text_box.bbcode_text = ''

func scroll_to_bottom():
	pass
	#_text_box.cursor_set_line(_gui.get_text_box().get_line_count())

func _set_font_size_for_rtl(rtl, new_size):
	if(rtl.get('custom_fonts/normal_font') != null):
		rtl.get('custom_fonts/bold_italics_font').size = new_size
		rtl.get('custom_fonts/bold_font').size = new_size
		rtl.get('custom_fonts/italics_font').size = new_size
		rtl.get('custom_fonts/normal_font').size = new_size


func _set_fonts_for_rtl(rtl, base_font_name):
	pass


func set_font_size(new_size):
	_font_size = new_size
	_set_font_size_for_rtl(_text_box, new_size)
	_set_font_size_for_rtl(_user_files.get_rich_text_label(), new_size)


func _set_font(rtl, font_name, custom_name):
	if(font_name == null):
		rtl.set('custom_fonts/' + custom_name, null)
	else:
		var dyn_font = DynamicFont.new()
		var font_data = DynamicFontData.new()
		font_data.font_path = 'res://addons/gut/fonts/' + font_name + '.ttf'
		font_data.antialiased = true
		dyn_font.font_data = font_data
		rtl.set('custom_fonts/' + custom_name, dyn_font)

func _set_all_fonts_in_ftl(ftl, base_name):
	if(base_name == 'Default'):
		_set_font(ftl, null, 'normal_font')
		_set_font(ftl, null, 'bold_font')
		_set_font(ftl, null, 'italics_font')
		_set_font(ftl, null, 'bold_italics_font')
	else:
		_set_font(ftl, base_name + '-Regular', 'normal_font')
		_set_font(ftl, base_name + '-Bold', 'bold_font')
		_set_font(ftl, base_name + '-Italic', 'italics_font')
		_set_font(ftl, base_name + '-BoldItalic', 'bold_italics_font')
	set_font_size(_font_size)

func set_font(base_name):
	_set_all_fonts_in_ftl(_text_box, base_name)
	_set_all_fonts_in_ftl(_user_files.get_rich_text_label(), base_name)

func set_default_font_color(color):
	_text_box.set('custom_colors/default_color', color)

func set_background_color(color):
	$Window/TextDisplay.color = color

func _on_UserFiles_pressed():
	_user_files.show_open()

func get_waiting_label():
	return $Window/TextDisplay/WaitingLabel
