################################################################################
#settings class
################################################################################
tool
extends WindowDialog

var _settings = {}
var _ok_button = null
var _cancel_button = null
var _scroll_up_button = null
var _scroll_down_button = null
var _scrollbar = null
var _prev_scroll_value = 1

const SIGNAL_OK_PRESSED = "ok_pressed"
const SIGNAL_CANCEL_PRESSED = "cancel_pressed"

const SETTING_HEIGHT = 30;

func _init():
	add_user_signal(SIGNAL_OK_PRESSED)
	add_user_signal(SIGNAL_CANCEL_PRESSED)	
	#Treat a hide the same as a cancel
	var x_button = self.get_close_button()
	x_button.connect("pressed", self, "_on_cancel_pressed")	
	
	_ok_button = Button.new()
	_ok_button.set_text("Ok")	
	_ok_button.set_size(Vector2(100, 50))
	_ok_button.connect("pressed", self, "_on_ok_pressed")
	add_child(_ok_button)
	
	_cancel_button = Button.new()
	_cancel_button.set_text("Cancel")
	_cancel_button.set_size(Vector2(100, 50))
	_cancel_button.connect("pressed", self, "_on_cancel_pressed")
	add_child(_cancel_button)
	
	_scroll_up_button = Button.new()
	_scroll_up_button.set_text("^")
	_scroll_up_button.set_size(Vector2(30, 30))
	_scroll_up_button.connect("pressed", self, "scroll_up")
	add_child(_scroll_up_button)

	_scroll_down_button = Button.new()
	_scroll_down_button.set_text("v")
	_scroll_down_button.set_size(Vector2(30, 30))
	_scroll_down_button.connect("pressed", self, "scroll_down")
	add_child(_scroll_down_button)
	
	_scrollbar = VScrollBar.new()
	_scrollbar.connect("value_changed", self, "_on_scroll_changed")
	_scrollbar.set_min(1)
	_scrollbar.set_max(2)
	_scrollbar.set_value(1)
	_scrollbar.set_page(1)
	_scrollbar.set_step(1)
	_scrollbar.set_unit_value(1)
	_scrollbar.set_rounded_values(true)
	add_child(_scrollbar)
	
#-------------------------------------------------------------------------------
func _ready():
	_ok_button.set_pos(self.get_size() - Vector2(110, 60))
	_ok_button.set_anchor(MARGIN_LEFT, ANCHOR_END)
	_ok_button.set_anchor(MARGIN_RIGHT, ANCHOR_END)
	_ok_button.set_anchor(MARGIN_TOP, ANCHOR_END)
	_ok_button.set_anchor(MARGIN_BOTTOM, ANCHOR_END)
	
	_cancel_button.set_pos(_ok_button.get_pos() - Vector2(120, 0))
	_cancel_button.set_anchor(MARGIN_LEFT, ANCHOR_END)
	_cancel_button.set_anchor(MARGIN_RIGHT, ANCHOR_END)
	_cancel_button.set_anchor(MARGIN_TOP, ANCHOR_END)
	_cancel_button.set_anchor(MARGIN_BOTTOM, ANCHOR_END)
	
	_scroll_up_button.set_pos(Vector2(self.get_size().x - 30, 0))
	_scroll_up_button.set_anchor(MARGIN_LEFT, ANCHOR_END)
	_scroll_up_button.set_anchor(MARGIN_RIGHT, ANCHOR_END)
	
	_scroll_down_button.set_pos(Vector2(self.get_size().x - 30, _ok_button.get_pos().y - 60))
	_scroll_down_button.set_anchor(MARGIN_LEFT, ANCHOR_END)
	_scroll_down_button.set_anchor(MARGIN_RIGHT, ANCHOR_END)
	_scroll_down_button.set_anchor(MARGIN_TOP, ANCHOR_END)
	_scroll_down_button.set_anchor(MARGIN_BOTTOM, ANCHOR_END)
	
	var scroll_height = _scroll_down_button.get_pos().y
	scroll_height -= _scroll_up_button.get_pos().y 
	scroll_height -= _scroll_up_button.get_size().y
	_scrollbar.set_pos(Vector2(get_size().x - 30, 30))
	_scrollbar.set_size(Vector2(30, scroll_height))	
	_scrollbar.set_anchor(MARGIN_LEFT, ANCHOR_END)
	_scrollbar.set_anchor(MARGIN_RIGHT, ANCHOR_END)
	_scrollbar.set_anchor(MARGIN_BOTTOM, ANCHOR_END)
	
#-------------------------------------------------------------------------------
#Hides controls when they are off of the panel.  Shows them when
#they are on the panel.
#-------------------------------------------------------------------------------
func _hide_offscreen(setting):
	#show hid controls when the scroll off screen
	var new_pos = setting.get_pos()
	if(new_pos.y < 0 or new_pos.y + SETTING_HEIGHT > _ok_button.get_pos().y):
		setting.hide()
	else:
		setting.show()

#-------------------------------------------------------------------------------
#Scrolls controls by the amount passed in.  It will hide controls
#as they scroll offscreen and show them as they scroll on screen.
#-------------------------------------------------------------------------------
func _scroll_controls(amount):
	var new_pos = null
	for key in _settings:
		#set new position
		new_pos = _settings[key].get_pos()
		new_pos += Vector2(0, amount)
		_settings[key].set_pos(new_pos)
		_hide_offscreen(_settings[key])

#-------------------------------------------------------------------------------
#Add a setting to the settings dictionary.  Sets the position so that the settings
#will appear in the order they were added.  Also hides any setting that is 
#added that would be off the panel.
#-------------------------------------------------------------------------------
func _append_setting(name, setting):	
	_settings[name] = setting
	setting.set_pos(Vector2(0, (_settings.size() - 1)* SETTING_HEIGHT))	
	setting.set_size(Vector2(self.get_size().x - 50, SETTING_HEIGHT))
	add_child(setting)
	
	_scrollbar.set_max(_scrollbar.get_max() + 1)
	
	_hide_offscreen(setting)
	if(setting.is_visible()):
		_scrollbar.set_page(_scrollbar.get_page() + 1)

#-------------------------------------------------------------------------------
#add a heading to the settings.  It has no functionality, just for display.
#-------------------------------------------------------------------------------
func add_heading(text):
	var new_heading = Heading.new()	
	new_heading.set_text(text)
	_append_setting("__heading__" + text, new_heading)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
func add_bool_setting(name, value, text=null, read_only=false):
	var new_setting = BoolSetting.new()
	if text == null:
		new_setting.set_text(name)
	else:
		new_setting.set_text(text)
	new_setting.set_value(value)
	new_setting.set_read_only(read_only)
	_append_setting(name, new_setting)
	
#-------------------------------------------------------------------------------
#Creates a new number setting and adds it to the dictionary
#-------------------------------------------------------------------------------
func add_number_setting(name, value, text=null, read_only=false, min_value=-32000, max_value=32000, increment=1 ):	
	var new_setting = NumberSetting.new()	
	if text == null:
		new_setting.set_text(name)
	else:
		new_setting.set_text(text)
	new_setting.set_value(value)
	new_setting.min_value = min_value
	new_setting.max_value = max_value
	new_setting.increment = increment
	new_setting.set_read_only(read_only)
	_append_setting(name, new_setting)

#-------------------------------------------------------------------------------
#Creates a new String setting and adds it to the dictionary
#-------------------------------------------------------------------------------
func add_string_setting(name, value, text=null, read_only=false):
	var new_setting = StringSetting.new()
	if text == null:
		new_setting.set_text(name)
	else:
		new_setting.set_text(text)
	new_setting.set_value(value)
	new_setting.set_read_only(read_only)
	_append_setting(name, new_setting)
	
#-------------------------------------------------------------------------------
func get_value(name):
	return _settings[name].get_value()

#-------------------------------------------------------------------------------
func scroll_up():
	_scrollbar.set_val(_scrollbar.get_val() - 1)

#-------------------------------------------------------------------------------
func scroll_down():
	_scrollbar.set_val(_scrollbar.get_val() + 1)

#-------------------------------------------------------------------------------
func _on_cancel_pressed():
	emit_signal(SIGNAL_CANCEL_PRESSED)

#-------------------------------------------------------------------------------
func _on_ok_pressed():
	var invalid_count = 0
	for key in _settings:
		if(!_settings[key]._is_valid):
			invalid_count += 1
	
	if(invalid_count == 0):
		emit_signal(SIGNAL_OK_PRESSED)
	else:
		print("must fix " + str(invalid_count) + " invalid items first")

#-------------------------------------------------------------------------------
func _on_scroll_changed(value):
	_scroll_controls((_prev_scroll_value - value) * SETTING_HEIGHT)
	_prev_scroll_value = value




################################################################################
#Setting
#	Base setting class, all settings below inherit from this one.
################################################################################
class Setting:
	extends Panel
	
	var _value = null
	var _is_valid = true
	var _label = null
	var _read_only = false
	
	func _init():
		_label = Label.new()
		_label.set_pos(Vector2(2, 2))
		_label.set_size(Vector2(100, 20))
		add_child(_label)
	
	func set_text(text):
		_label.set_text(text)
	
	func get_text():
		return _label.get_text()
	
	func set_value(value):
		_value = value
	
	func get_value():
		return _value
	
	func set_read_only(value):
		_read_only = value
	
	func get_read_only():
		return _read_only




################################################################################
#Heading class
#	Simple setting that is for display only.  Used as a divider of settings or
#	just for info.
################################################################################
class Heading:
	extends Setting
	var _seperator_top = null
	var _seperator_bottom = null
	
	func _init():		
		._init()
		_seperator_top = HSeparator.new()
		_seperator_top.set_pos(Vector2(0,0))
		add_child(_seperator_top)
		
		_seperator_bottom = HSeparator.new()
		_seperator_bottom.set_pos(Vector2(0, 22))
		add_child(_seperator_bottom)
		
	func _ready():
		_seperator_top.set_size(Vector2(self.get_size().x, 1))
		_seperator_bottom.set_size(Vector2(self.get_size().x, 1))




################################################################################
#BoolSetting class
#	Setting for a boolean value.
################################################################################
class BoolSetting:
	extends Setting
	
	var _check_button = null
	
	func _init():
		._init()
		
		_check_button = CheckButton.new()
		_check_button.set_size(Vector2(50, 30))
		_check_button.set_pos(Vector2(105, 0))
		_check_button.set_toggle_mode(true)
		_check_button.connect("toggled", self, "_on_check_button_toggled")
		add_child(_check_button)

	func _on_check_button_toggled(value):
		_value = value

	func set_value(value):
		_value = value
		_check_button.set_pressed(_value)
		
	func set_read_only(value):
		_read_only = value
		_check_button.set_disabled(value)




################################################################################
#NumberSetting class
#	A Panel control that allows the editing of a numeric value.  It contains increment
#	and decrement buttons, a hint box to indicate when there is something wrong
#	with the value, a label and an input box.
################################################################################
class NumberSetting:
	extends Setting
	#controls	
	var _text_box = null
	var _hint = null
	var _increment_button = null
	var _decrement_button = null
	
	#properties
	var increment = 1
	var min_value = -32000
	var max_value = 32000
	var name = 'number setting'
	
	#---------------------------------------------------------------------------
	func _init():
		._init()
		#Setup label
		_label.set_text("Number Setting")
		
		#Setup input box
		_text_box = LineEdit.new()
		_text_box.set_pos(Vector2(102, 2))
		_text_box.set_size(Vector2(200, 20))
		_text_box.set_text(str(_value))
		_text_box.connect("text_changed", self, "_on_value_text_changed")
		add_child(_text_box)
		
		#Setup decrement button
		_decrement_button = Button.new()
		_decrement_button.set_pos(Vector2(302, 2))
		_decrement_button.set_size(Vector2(32, 25))
		_decrement_button.set_text("-")
		_decrement_button.connect("pressed", self, "_on_decrement_pressed")
		add_child(_decrement_button)
		
		#Setup increment button
		_increment_button = Button.new()
		_increment_button.set_pos(Vector2(334, 2))
		_increment_button.set_size(Vector2(32, 25))
		_increment_button.set_text("+")
		_increment_button.connect("pressed", self, "_on_increment_pressed")
		add_child(_increment_button)
		
		#Setup hint label
		_hint = Label.new()
		_hint.set_pos(Vector2(366, 2))
		_hint.set_size(Vector2(200, 20))
		add_child(_hint)
	
	#---------------------------------------------------------------------------
	#Determins if the value is a valid number within the range of _min_value and
	#_max_value (inclusive) and sets the hint text and _is_valid accordingly.
	#---------------------------------------------------------------------------
	func _determine_validity():
		var temp_val = 0
		if(_text_box.get_text().is_valid_float()):
			temp_val = _text_box.get_text().to_float()
			if(temp_val < min_value):
				_hint.set_text("Value must be >= " + str(min_value))
				_is_valid = false
			elif(temp_val > max_value):
				_hint.set_text("Value must be <= " + str(max_value))
				_is_valid = false
			else:
				_hint.set_text("")
				_is_valid = true
		else:
			_is_valid = false
			_hint.set_text("invalid number")
	

	#---------------------------------------------------------------------------
	func _ready():
		set_value(_value)

	#---------------------------------------------------------------------------
	func set_value(value):
		_value = value
		_text_box.set_text(str(value))
		_is_valid = _text_box.get_text().is_valid_float()

	#---------------------------------------------------------------------------
	#must overwrite base to cast value
	#---------------------------------------------------------------------------
	func get_value():
		return _text_box.get_text().to_int()

	
	#---------------------------------------------------------------------------
	#Increment the value if we can.
	#---------------------------------------------------------------------------
	func _on_increment_pressed():
		if(_is_valid):
			if(_value + increment < max_value):
				_value += increment
			else:
				_value = max_value
			_text_box.set_text(str(_value))
			_determine_validity()

	#---------------------------------------------------------------------------
	func _on_decrement_pressed():
		if(_is_valid):
			if(_value - increment > min_value):
				_value -= increment
			else:
				_value = min_value
			_text_box.set_text(str(_value))
			_determine_validity()

	#---------------------------------------------------------------------------
	func _on_value_text_changed(text):
		#found a bug where you can alter a readonly TextEdit control
		#so I'm bypasing validation on disabled controls and reseting
		#value if disabled.
		if(!_read_only):
			_determine_validity()
			if(_is_valid):
				_value = _text_box.get_text().to_float()
		else:
			_text_box.set_text(str(_value))

	#---------------------------------------------------------------------------
	func set_read_only(read_only):
		_read_only = read_only
		_text_box.set_editable(!read_only)
		_decrement_button.set_disabled(read_only)
		_increment_button.set_disabled(read_only)




################################################################################
#
################################################################################
class StringSetting:
	extends Setting
	var _text_box = null
	
	#---------------------------------------------------------------------------
	func _init():
		._init()
		
		#Setup input box
		_text_box = LineEdit.new()
		_text_box.set_pos(Vector2(102, 2))
		_text_box.set_size(Vector2(200, 20))
		_text_box.set_text(str(_value))
		_text_box.connect("text_changed", self, "_on_value_text_changed")
		add_child(_text_box)
	
	#---------------------------------------------------------------------------
	func set_value(value):
		_value = value
		_text_box.set_text(value)
		
	#---------------------------------------------------------------------------
	func _on_value_text_changed(text):
		#found a bug where you can alter a readonly TextEdit control
		#so I reset the value if it changes.
		if(!_read_only):
			_value = _text_box.get_text()
		else:
			_text_box.set_text(str(_value))
	
	#---------------------------------------------------------------------------
	func set_read_only(read_only):
		_read_only = read_only
		_text_box.set_editable(!read_only)
	

