################################################################################
#The MIT License (MIT)
#=====================
#
#Copyright (c) 2017 Tom "Butch" Wesley
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.
#
################################################################################

################################################################################
# This class contains all the GUI creation code for Gut.  It was split out and
# hopefully can be moved to a scene in the future.
################################################################################
extends WindowDialog

# various counters
var _summary = {
	asserts = 0,
	passed = 0,
	failed = 0,
	tests = 0,
	scripts = 0,
	pending = 0,
	moved_methods = 0,
	# these are used to display the tally in the top right corner.  Since the
	# implementation changed to summing things up at the end, the running
	# update wasn't showing.  Hack.
	tally_passed = 0,
	tally_failed = 0
}

var _is_running = false
var min_size = Vector2(650, 400)

#controls
var _ctrls = {
	text_box = TextEdit.new(),
	run_button = Button.new(),
	copy_button = Button.new(),
	clear_button = Button.new(),
	continue_button = Button.new(),
	log_level_slider = HSlider.new(),
	scripts_drop_down = OptionButton.new(),
	next_button = Button.new(),
	previous_button = Button.new(),
	stop_button = Button.new(),
	script_progress = ProgressBar.new(),
	test_progress = ProgressBar.new(),
	runtime_label = Label.new(),
	ignore_continue_checkbox = CheckBox.new(),
	pass_count = Label.new(),
	run_rest = Button.new()
}

var _mouse_down = false
var _mouse_down_pos = null
var _mouse_in = false

func _set_anchor_top_right(obj):
	obj.set_anchor(MARGIN_RIGHT, ANCHOR_BEGIN)
	obj.set_anchor(MARGIN_LEFT, ANCHOR_END)
	obj.set_anchor(MARGIN_TOP, ANCHOR_BEGIN)

func _set_anchor_bottom_right(obj):
	obj.set_anchor(MARGIN_LEFT, ANCHOR_END)
	obj.set_anchor(MARGIN_RIGHT, ANCHOR_END)
	obj.set_anchor(MARGIN_TOP, ANCHOR_END)
	obj.set_anchor(MARGIN_BOTTOM, ANCHOR_END)

func _set_anchor_bottom_left(obj):
	obj.set_anchor(MARGIN_LEFT, ANCHOR_BEGIN)
	obj.set_anchor(MARGIN_TOP, ANCHOR_END)
	obj.set_anchor(MARGIN_TOP, ANCHOR_END)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func setup_controls():
	var button_size = Vector2(75, 35)
	var button_spacing = Vector2(10, 0)
	var pos = Vector2(0, 0)

	add_child(_ctrls.text_box)
	_ctrls.text_box.set_size(Vector2(get_size().x - 4, 300))
	_ctrls.text_box.set_position(Vector2(2, 0))
	_ctrls.text_box.set_readonly(true)
	_ctrls.text_box.set_syntax_coloring(true)
	_ctrls.text_box.set_anchor(MARGIN_LEFT, ANCHOR_BEGIN)
	_ctrls.text_box.set_anchor(MARGIN_RIGHT, ANCHOR_END)
	_ctrls.text_box.set_anchor(MARGIN_TOP, ANCHOR_BEGIN)
	_ctrls.text_box.set_anchor(MARGIN_BOTTOM, ANCHOR_END)

	add_child(_ctrls.copy_button)
	_ctrls.copy_button.set_text("Copy")
	_ctrls.copy_button.set_size(button_size)
	_ctrls.copy_button.set_position(Vector2(get_size().x - 5 - button_size.x, _ctrls.text_box.get_size().y + 10))
	_set_anchor_bottom_right(_ctrls.copy_button)

	add_child(_ctrls.clear_button)
	_ctrls.clear_button.set_text("Clear")
	_ctrls.clear_button.set_size(button_size)
	_ctrls.clear_button.set_position(_ctrls.copy_button.get_position() - Vector2(button_size.x, 0) - button_spacing)
	_set_anchor_bottom_right(_ctrls.clear_button)

	add_child(_ctrls.pass_count)
	_ctrls.pass_count.set_text('0 - 0')
	_ctrls.pass_count.set_size(Vector2(100, 30))
	_ctrls.pass_count.set_position(Vector2(550, 0))
	_ctrls.pass_count.set_align(HALIGN_RIGHT)
	_set_anchor_top_right(_ctrls.pass_count)

	add_child(_ctrls.continue_button)
	_ctrls.continue_button.set_text("Continue")
	_ctrls.continue_button.set_size(Vector2(100, 25))
	_ctrls.continue_button.set_position(Vector2(_ctrls.clear_button.get_position().x, _ctrls.clear_button.get_position().y + _ctrls.clear_button.get_size().y + 10))
	_ctrls.continue_button.set_disabled(true)
	_set_anchor_bottom_right(_ctrls.continue_button)

	add_child(_ctrls.ignore_continue_checkbox)
	_ctrls.ignore_continue_checkbox.set_text("Ignore pauses")
	#_ctrls.ignore_continue_checkbox.set_pressed(_ignore_pause_before_teardown)
	_ctrls.ignore_continue_checkbox.set_size(Vector2(50, 30))
	_ctrls.ignore_continue_checkbox.set_position(Vector2(_ctrls.continue_button.get_position().x, _ctrls.continue_button.get_position().y + _ctrls.continue_button.get_size().y - 5))
	_set_anchor_bottom_right(_ctrls.ignore_continue_checkbox)

	var log_label = Label.new()
	add_child(log_label)
	log_label.set_text("Log Level")
	log_label.set_position(Vector2(10, _ctrls.text_box.get_size().y + 1))
	_set_anchor_bottom_left(log_label)

	add_child(_ctrls.log_level_slider)
	_ctrls.log_level_slider.set_size(Vector2(75, 30))
	_ctrls.log_level_slider.set_position(Vector2(10, log_label.get_position().y + 20))
	_ctrls.log_level_slider.set_min(0)
	_ctrls.log_level_slider.set_max(2)
	_ctrls.log_level_slider.set_ticks(3)
	_ctrls.log_level_slider.set_ticks_on_borders(true)
	_ctrls.log_level_slider.set_step(1)
	#_ctrls.log_level_slider.set_rounded_values(true)
	#_ctrls.log_level_slider.set_value(_log_level)
	_set_anchor_bottom_left(_ctrls.log_level_slider)

	var script_prog_label = Label.new()
	add_child(script_prog_label)
	script_prog_label.set_position(Vector2(100, log_label.get_position().y))
	script_prog_label.set_text('Scripts:')
	_set_anchor_bottom_left(script_prog_label)

	add_child(_ctrls.script_progress)
	_ctrls.script_progress.set_size(Vector2(200, 10))
	_ctrls.script_progress.set_position(script_prog_label.get_position() + Vector2(70, 0))
	_ctrls.script_progress.set_min(0)
	_ctrls.script_progress.set_max(1)
	_ctrls.script_progress.set_step(1)
	_set_anchor_bottom_left(_ctrls.script_progress)

	var test_prog_label = Label.new()
	add_child(test_prog_label)
	test_prog_label.set_position(Vector2(100, log_label.get_position().y + 15))
	test_prog_label.set_text('Tests:')
	_set_anchor_bottom_left(test_prog_label)

	add_child(_ctrls.test_progress)
	_ctrls.test_progress.set_size(Vector2(200, 10))
	_ctrls.test_progress.set_position(test_prog_label.get_position() + Vector2(70, 0))
	_ctrls.test_progress.set_min(0)
	_ctrls.test_progress.set_max(1)
	_ctrls.test_progress.set_step(1)
	_set_anchor_bottom_left(_ctrls.test_progress)

	add_child(_ctrls.previous_button)
	_ctrls.previous_button.set_size(Vector2(50, 25))
	pos = _ctrls.test_progress.get_position() + Vector2(250, 25)
	pos.x -= 300
	_ctrls.previous_button.set_position(pos)
	_ctrls.previous_button.set_text("<")
	_set_anchor_bottom_left(_ctrls.previous_button)

	add_child(_ctrls.stop_button)
	_ctrls.stop_button.set_size(Vector2(50, 25))
	pos.x += 60
	_ctrls.stop_button.set_position(pos)
	_ctrls.stop_button.set_text('stop')
	_set_anchor_bottom_left(_ctrls.stop_button)

	add_child(_ctrls.run_rest)
	_ctrls.run_rest.set_text('run')
	_ctrls.run_rest.set_size(Vector2(50, 25))
	pos.x += 60
	_ctrls.run_rest.set_position(pos)
	_set_anchor_bottom_left(_ctrls.run_rest)

	add_child(_ctrls.next_button)
	_ctrls.next_button.set_size(Vector2(50, 25))
	pos.x += 60
	_ctrls.next_button.set_position(pos)
	_ctrls.next_button.set_text(">")
	_set_anchor_bottom_left(_ctrls.next_button)

	add_child(_ctrls.runtime_label)
	_ctrls.runtime_label.set_text('0.0')
	_ctrls.runtime_label.set_size(Vector2(50, 30))
	_ctrls.runtime_label.set_position(Vector2(_ctrls.clear_button.get_position().x - 90, _ctrls.next_button.get_position().y))
	_set_anchor_bottom_right(_ctrls.runtime_label)

	# the drop down has to be one of the last added so that when then list of
	# scripts is displayed, other controls do not get in the way of selecting
	# an item in the list.
	add_child(_ctrls.scripts_drop_down)
	_ctrls.scripts_drop_down.set_size(Vector2(375, 25))
	_ctrls.scripts_drop_down.set_position(Vector2(10, _ctrls.log_level_slider.get_position().y + 50))
	_set_anchor_bottom_left(_ctrls.scripts_drop_down)
	_ctrls.scripts_drop_down.set_clip_text(true)

	add_child(_ctrls.run_button)
	_ctrls.run_button.set_text('<- run')
	_ctrls.run_button.set_size(Vector2(50, 25))
	_ctrls.run_button.set_position(_ctrls.scripts_drop_down.get_position() + Vector2(_ctrls.scripts_drop_down.get_size().x + 5, 0))
	_set_anchor_bottom_left(_ctrls.run_button)

func set_it_up():
	self.set_size(min_size)
	setup_controls()
	self.connect("mouse_enter", self, "_on_mouse_enter")
	self.connect("mouse_exit", self, "_on_mouse_exit")
	set_process(true)
	set_pause_mode(PAUSE_MODE_PROCESS)
	_update_controls()

#-------------------------------------------------------------------------------
# Updates the display
#-------------------------------------------------------------------------------
func _update_controls():

	if(_is_running):
		_ctrls.previous_button.set_disabled(true)
		_ctrls.next_button.set_disabled(true)
		_ctrls.pass_count.show()
	else:
		_ctrls.previous_button.set_disabled(_ctrls.scripts_drop_down.get_selected() <= 0)
		_ctrls.next_button.set_disabled(_ctrls.scripts_drop_down.get_selected() != -1 and _ctrls.scripts_drop_down.get_selected() == _ctrls.scripts_drop_down.get_item_count() -1)
		_ctrls.pass_count.hide()

	# disabled during run
	_ctrls.run_button.set_disabled(_is_running)
	_ctrls.run_rest.set_disabled(_is_running)
	_ctrls.scripts_drop_down.set_disabled(_is_running)

	# enabled during run
	_ctrls.stop_button.set_disabled(!_is_running)
	_ctrls.pass_count.set_text(str( _summary.tally_passed, ' - ', _summary.tally_failed))


#-------------------------------------------------------------------------------
#detect mouse movement
#-------------------------------------------------------------------------------
func _on_mouse_enter():
	_mouse_in = true

#-------------------------------------------------------------------------------
#detect mouse movement
#-------------------------------------------------------------------------------
func _on_mouse_exit():
	_mouse_in = false
	_mouse_down = false


#-------------------------------------------------------------------------------
#Send text box text to clipboard
#-------------------------------------------------------------------------------
func _copy_button_pressed():
	_ctrls.text_box.select_all()
	_ctrls.text_box.copy()


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func _init_run():
	_ctrls.text_box.clear_colors()
	_ctrls.text_box.add_keyword_color("PASSED", Color(0, 1, 0))
	_ctrls.text_box.add_keyword_color("FAILED", Color(1, 0, 0))
	_ctrls.text_box.add_color_region('/#', '#/', Color(.9, .6, 0))
	_ctrls.text_box.add_color_region('/-', '-/', Color(1, 1, 0))
	_ctrls.text_box.add_color_region('/*', '*/', Color(.5, .5, 1))
	#_ctrls.text_box.set_symbol_color(Color(.5, .5, .5))
	_ctrls.runtime_label.set_text('0.0')
	_ctrls.test_progress.set_max(1)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func _input(event):
	#if the mouse is somewhere within the debug window
	if(_mouse_in):
		#Check for mouse click inside the resize handle
		if(event.type == InputEvent.MOUSE_BUTTON):
			if (event.button_index == 1):
				#It's checking a square area for the bottom right corner, but that's close enough.  I'm lazy
				if(event.pos.x > get_size().x + get_position().x - 10 and event.pos.y > get_size().y + get_position().y - 10):
					if event.pressed:
						_mouse_down = true
						_mouse_down_pos = event.pos
					else:
						_mouse_down = false
		#Reszie
		if(event.type == InputEvent.MOUSE_MOTION):
			if(_mouse_down):
				if(get_size() >= min_size):
					var new_size = get_size() + event.pos - _mouse_down_pos
					var new_mouse_down_pos = event.pos

					if(new_size.x < min_size.x):
						new_size.x = min_size.x
						new_mouse_down_pos.x = _mouse_down_pos.x

					if(new_size.y < min_size.y):
						new_size.y = min_size.y
						new_mouse_down_pos.y = _mouse_down_pos.y

					_mouse_down_pos = new_mouse_down_pos
					set_size(new_size)

#-------------------------------------------------------------------------------
#Custom drawing to indicate results.
#-------------------------------------------------------------------------------
func _draw():
	#Draw the lines in the corner to show where you can
	#drag to resize the dialog
	var grab_margin = 2
	var line_space = 3
	var grab_line_color = Color(.4, .4, .4)
	for i in range(1, 6):
		draw_line(get_size() - Vector2(i * line_space, grab_margin), get_size() - Vector2(grab_margin, i * line_space), grab_line_color)

	return

	var where = Vector2(430, 565)
	var r = 25
	if(_summary.tests > 0):
		if(_summary.failed > 0):
			draw_circle(where, r , Color(1, 0, 0, 1))
		else:
			draw_circle(where, r, Color(0, 1, 0, 1))
