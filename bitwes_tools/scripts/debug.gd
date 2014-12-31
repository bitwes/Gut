tool
extends WindowDialog

var _hide_button = null
var _copy_button = null
var _clear_button = null
var _text_box = null
var _entries = []
var print_to_console = false
var enabled = true

func _init():
	_hide_button = Button.new()	
	_hide_button.set_text("Hide")	
	_hide_button.connect("pressed", self, "_on_hide_pressed")
	add_child(_hide_button)
	
	_copy_button = Button.new()
	_copy_button.set_text("Copy")
	_copy_button.connect("pressed", self, "_on_copy_pressed")
	add_child(_copy_button)

	_clear_button = Button.new()
	_clear_button.set_text("Clear")
	_clear_button.connect("pressed", self, "_on_clear_pressed")
	add_child(_clear_button)

	_text_box = TextEdit.new()
	_text_box.set_wrap(false)
	_text_box.set_readonly(true)
	add_child(_text_box)
	
	self.set_title("Debug Output")
	
func _ready():
	_hide_button.set_size(Vector2(100, 50))
	_hide_button.set_pos(self.get_size() - _hide_button.get_size() - Vector2(10, 10))
	_hide_button.set_anchor(MARGIN_LEFT, ANCHOR_END)
	_hide_button.set_anchor(MARGIN_RIGHT, ANCHOR_END)
	_hide_button.set_anchor(MARGIN_TOP, ANCHOR_END)
	_hide_button.set_anchor(MARGIN_BOTTOM, ANCHOR_END)
	
	_copy_button.set_size(Vector2(100, 50))
	_copy_button.set_pos(_hide_button.get_pos() - Vector2(110, 0))
	_copy_button.set_anchor(MARGIN_LEFT, ANCHOR_END)
	_copy_button.set_anchor(MARGIN_RIGHT, ANCHOR_END)
	_copy_button.set_anchor(MARGIN_TOP, ANCHOR_END)
	_copy_button.set_anchor(MARGIN_BOTTOM, ANCHOR_END)

	_clear_button.set_size(Vector2(100, 50))
	_clear_button.set_pos(_copy_button.get_pos() - Vector2(110, 0))
	_clear_button.set_anchor(MARGIN_LEFT, ANCHOR_END)
	_clear_button.set_anchor(MARGIN_RIGHT, ANCHOR_END)
	_clear_button.set_anchor(MARGIN_TOP, ANCHOR_END)
	_clear_button.set_anchor(MARGIN_BOTTOM, ANCHOR_END)

	_text_box.set_size(self.get_size() - Vector2(6, 70))
	_text_box.set_pos(Vector2(3, 3))
	_text_box.set_anchor(MARGIN_LEFT, ANCHOR_BEGIN)
	_text_box.set_anchor(MARGIN_RIGHT, ANCHOR_END)
	_text_box.set_anchor(MARGIN_TOP, ANCHOR_BEGIN)
	_text_box.set_anchor(MARGIN_BOTTOM, ANCHOR_END)

func _on_hide_pressed():
	self.hide()

func _on_copy_pressed():
	_text_box.select_all()
	_text_box.copy()
	_text_box.select(0, 0, 0, 0)

func _on_clear_pressed():
	_entries.clear()
	_text_box.set_text("")

func p(text):
	if(enabled):
		var entry = DebugEntry.new()
		var last_entry = null
		#indent any extra lines in the text so that all the text lines up
		var to_print = text.replacen("\n", "\n\t\t\t\t\t")
		
		if(!_entries.empty()):
			last_entry = _entries[_entries.size() -1]
		
		#If the entry is the same then we clear out the last entry so we can print the new
		#one with a higher counter.
		if(last_entry != null and to_print.casecmp_to(last_entry.text) == 0 and last_entry.timestamps_equal(entry)):
			last_entry.count += 1
			
			#count the lines in the text.
			var lines = 1
			if(!to_print.empty()):
				lines = 1
				var where = to_print.findn("\n", 0)
				while(where != -1):
					lines += 1
					where = to_print.findn("\n", where +1)
			
			#Selecting text then inserting at cursor will replace the 
			#text that is selected.  This erases that text since we
			#have a duplicate
			_text_box.select(0, 0, lines, 0)
			_text_box.insert_text_at_cursor("")
		else:
			entry.text = text
			_entries.append(entry)
			
		_text_box.cursor_set_column(0)
		_text_box.cursor_set_line(0)
		_text_box.insert_text_at_cursor(_entries[_entries.size() - 1].to_string() + "\n")

		if(print_to_console):
			print("[" + entry.get_timestamp_as_string() + "] " + to_print)




################################################################################
#DebugEntry Class
#	Data structure for a debug entry with some methods for getting data back 
#	out as a string.  The timestamp is set when new() is called, so you don't 
#	have to do that unless you don't want to use the time it was created as 
#	the timestamp.
################################################################################
class DebugEntry:
	var text = ""
	var timestamp = null
	var count = 1
	
	func _init():
		timestamp = OS.get_time()
	
	func get_timestamp_as_string():
		return str(timestamp['hour']).pad_zeros(2) + ":" + str(timestamp['minute']).pad_zeros(2) + ":" + str(timestamp['second']).pad_zeros(2)
	
	func to_string():
		var to_return = "[" + get_timestamp_as_string() + "]\t" + text
		if(count > 1):
			to_return += "  (" + str(count) + ")"
		
		return to_return
	
	func timestamps_equal(other_entry):
		return other_entry.get_timestamp_as_string().casecmp_to(self.get_timestamp_as_string()) == 0
