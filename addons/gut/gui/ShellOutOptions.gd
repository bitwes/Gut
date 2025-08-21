@tool
extends ConfirmationDialog

const RUN_MODE_EDITOR = 'Editor'
const RUN_MODE_BLOCKING = 'Blocking'
const RUN_MODE_NON_BLOCKING = 'NonBlocking'

var GutEditorGlobals = load('res://addons/gut/gui/editor_globals.gd')

var _blurb_style_box = StyleBoxEmpty.new()
var _opt_maker_setup = false
var _additional_arguments_ctrls = []

# Run mode button stuff
var _run_mode_theme = load('res://addons/gut/gui/EditorRadioButton.tres')
var _button_group = ButtonGroup.new()
var _btn_in_editor : Button = null
var _btn_blocking : Button = null
var _btn_non_blocking : Button = null
var _txt_additional_arguments = null


var opt_maker = null
var default_path = GutEditorGlobals.run_externally_options_path

# I like this.  It holds values loaded/saved which makes for an easy 
# reset mechanism.  Hit OK; values get written to this object (not the file
# system).  Hit Cancel; values are reloaded from this object.  Call the 
# save/load methods to interact with the file system.
#
# Downside:  If the keys/sections in the config file change, this ends up 
#            preserving old data.  So you gotta find a way to clean it out 
#            somehow. 
# Downside solved:  Clear the config file at the start of the save method.
var _config_file = ConfigFile.new()

var _run_mode = RUN_MODE_EDITOR
var run_mode = _run_mode:
	set(val):
		_run_mode = val
		if(is_inside_tree()):
			_btn_in_editor.button_pressed = _run_mode == RUN_MODE_EDITOR
			_btn_blocking.button_pressed = _run_mode == RUN_MODE_BLOCKING
			_btn_non_blocking.button_pressed = _run_mode == RUN_MODE_NON_BLOCKING
	get():
		return _run_mode


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
	_button_group.pressed.connect(_on_mode_button_pressed)
	run_mode = run_mode
	
	
func _on_mode_button_pressed(which):
	for ctrl in _additional_arguments_ctrls:
		if(which == _btn_in_editor):
			ctrl.modulate.a = .3
		else:
			ctrl.modulate.a = 1.0

	_txt_additional_arguments.value_ctrl.editable = which != _btn_in_editor
	if(which == _btn_in_editor):
		_run_mode = RUN_MODE_EDITOR
	elif(which == _btn_blocking):
		_run_mode = RUN_MODE_BLOCKING
	elif(which == _btn_non_blocking):
		_run_mode = RUN_MODE_NON_BLOCKING


func _add_run_mode_button(text):
	var hbox = HBoxContainer.new()
	
	var spacer = CenterContainer.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.size_flags_stretch_ratio = .5
	hbox.add_child(spacer)
	
	var btn = Button.new()
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.toggle_mode = true
	btn.text = text
	btn.button_group = _button_group
	btn.theme = _run_mode_theme
	hbox.add_child(btn)

	spacer = spacer.duplicate()
	hbox.add_child(spacer)

	$ScrollContainer/VBoxContainer.add_child(hbox)
	return btn


func _add_blurb(text):
	var ctrl = opt_maker.add_blurb(text)
	ctrl.set("theme_override_styles/normal", _blurb_style_box)
	return ctrl

	
func _add_title(text):
	var ctrl = opt_maker.add_title(text)
	ctrl.get_child(0).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return ctrl


func _add_controls():
	var ctrl = null
	_add_title("Run Modes")
	_add_blurb(
		"Choose how GUT will launch tests.  Normally you just run them through the editor, but now " + 
		"you can run them externally.  The Modes are described below.")
	
	_btn_in_editor = _add_run_mode_button("In Editor (default)")
	_btn_blocking = _add_run_mode_button("Externally - Blocking")
	_btn_non_blocking = _add_run_mode_button("Externally - NonBlocking")
	
	ctrl = _add_title("Command Line Arguments")
	_additional_arguments_ctrls.append(ctrl)
	ctrl = _add_blurb(
		"Supply any command line options for GUT and/or Godot when running externally.  You cannot use " + 
		"spaces in values.  See the Godot command line help for options and the GUT documentation " + 
		"for optons.")
	_additional_arguments_ctrls.append(ctrl)
	_txt_additional_arguments = opt_maker.add_value("additional_arguments", additional_arguments, '', '')
	_additional_arguments_ctrls.append(_txt_additional_arguments)
	
	_add_title("Run Mode Descriptions")
	_add_blurb("[b]In Editor[/b]")
	_add_blurb("This is the default.  Runs through the editor.  When an error occurs " + 
		"in your test code or code under test, then the debugger is invoked.")

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

	_opt_maker_setup = true


func _save_to_config_file(f : ConfigFile):
	f.clear()
	f.set_value('main', 'run_mode', run_mode)
	f.set_value('main', 'additional_arguments', opt_maker.controls.additional_arguments.value)


func save_to_file(path = default_path):
	_save_to_config_file(_config_file)
	_config_file.save(path)


func _load_from_config_file(f):
	run_mode = f.get_value('main', 'run_mode', RUN_MODE_EDITOR)
	opt_maker.controls.additional_arguments.value = \
		f.get_value('main', 'additional_arguments', '')


func load_from_file(path = default_path):
	_config_file.load(path)
	_load_from_config_file(_config_file)


func reset():
	_load_from_config_file(_config_file)


func get_additional_arguments_array():
	return additional_arguments.split(" ", false)


func should_run_externally():
	return run_mode != RUN_MODE_EDITOR
