@tool
extends ConfirmationDialog

var GutEditorGlobals = load('res://addons/gut/gui/editor_globals.gd')

var _blurb_style_box = StyleBoxEmpty.new()
var _opt_maker_setup = false
var opt_maker = null
var default_path = GutEditorGlobals.run_externally_options_path

# I like this.  It holds values loaded/saved which makes for an easy 
# reset mechanism.  Hit OK; values get written to this object (not the file
# system).  Hit Cancel; values are reloaded from this object.  Call the 
# save/load methods to interact with the file system.
var _config_file = ConfigFile.new()

var blocking_mode = 'Blocking' :
	get():
		if(_opt_maker_setup):
			return opt_maker.controls.blocking_mode.text
		else:
			return blocking_mode


var additional_arguments = '' :
	get():
		if(_opt_maker_setup):
			return opt_maker.controls.additional_arguments.value
		else:
			return additional_arguments


func _debug_ready():
	popup_centered()
	default_path = GutEditorGlobals.temp_directory.path_join('test_external_run_options.cfg')
	exclusive = false
	
	var save_btn = Button.new()
	save_btn.text = 'save'
	save_btn.pressed.connect(func():
		save_to_file()
		print(_config_file.encode_to_text()))
	save_btn.position = Vector2(100, 20)
	save_btn.size = Vector2(100, 100)
	get_tree().root.add_child(save_btn)
	
	var load_btn = Button.new()
	load_btn.text = 'load'
	load_btn.pressed.connect(func():
		load_from_file()
		print(_config_file.encode_to_text()))
	load_btn.position = Vector2(100, 130)
	load_btn.size = Vector2(100, 100)
	get_tree().root.add_child(load_btn)
	
	var show_btn = Button.new()
	show_btn.text = 'Show'
	show_btn.pressed.connect(popup_centered)
	show_btn.position = Vector2(100, 250)
	show_btn.size = Vector2(100, 100)
	get_tree().root.add_child(show_btn)


func _ready():
	opt_maker = GutUtils.OptionMaker.new($ScrollContainer/VBoxContainer)
	_add_controls()
	
	if(get_parent() == get_tree().root):
		_debug_ready.call_deferred()
	
	canceled.connect(reset)
	confirmed.connect(_save_to_config_file.bind(_config_file))
	
	
func _add_blurb(text):
	var ctrl = opt_maker.add_blurb(text)
	ctrl.set("theme_override_styles/normal", _blurb_style_box)
	return ctrl
	

func _add_controls():
	opt_maker.add_title("External Run Options")
	_add_blurb(
		"These options affect how GUT is run when not run through the editor.  The main reason why " + 
		"you would not want to run through the editor is so that you can disable the debugger.  " + 
		"That's the main reason it was made, you might have other reasons.")
	
	opt_maker.add_title('Blocking Mode')
	_add_blurb("[b]Blocking[/b]")
	_add_blurb(
		"Errors appear in the output as they would if run from the command line, but the editor " + 
		"cannot be used while tests are running.  If you are trying to test for errors, this " + 
		"mode provides the best output.")
	_add_blurb("[b]Non-Blocking[/b]")
	_add_blurb(
		"Test output is streamed to the GUT panel but error output appears after all tests have " + 
		"finished.  The editor is not blocked.  If you want to run tests with the --headless option, " +
		"you can use this mode to see what the run is doing.")
	opt_maker.add_select('blocking_mode', blocking_mode, ['Blocking', 'Non-Blocking'], '')
	
	opt_maker.add_title("Additional Arguments")
	_add_blurb(
		"Supply any additional command line options for GUT and/or Godot.  You cannot use " + 
		"spaces in values.  See the Godot command line help for options and the GUT documentation " + 
		"for optons.")
	opt_maker.add_value("additional_arguments", additional_arguments, '', '')
	_opt_maker_setup = true


func _save_to_config_file(f):
	f.set_value('main', 'blocking_mode', opt_maker.controls.blocking_mode.value)
	f.set_value('main', 'additional_arguments', opt_maker.controls.additional_arguments.value)
	

func save_to_file(path = default_path):
	_save_to_config_file(_config_file)
	_config_file.save(path)
	

func _load_from_config_file(f):
	opt_maker.controls.blocking_mode.value = \
		f.get_value('main', 'blocking_mode', 0)
	opt_maker.controls.additional_arguments.value = \
		f.get_value('main', 'additional_arguments', '')


func load_from_file(path = default_path):
	_config_file.load(path)
	_load_from_config_file(_config_file)


func reset():
	_load_from_config_file(_config_file)


func get_additional_arguments_array():
	return additional_arguments.split(" ", false)
