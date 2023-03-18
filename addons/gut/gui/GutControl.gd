# ##############################################################################
#The MIT License (MIT)
#=====================
#
#Copyright (c) 2023 Tom "Butch" Wesley
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
# ##############################################################################
@tool
extends Control

# ##############################################################################
#
# Description:
# ------------
# This file is used to illustrate how you would Run tests on a deployed project
# and some of the ways to interact with GUT, the runner, and a config.
#
# ##############################################################################
const RUNNER_JSON_PATH = 'res://.gut_editor_config.json'

var GutConfig = load('res://addons/gut/gut_config.gd')
var GutRunnerScene = load('res://addons/gut/gui/GutRunner.tscn')
var GutConfigGui = load('res://addons/gut/gui/gut_config_gui.gd')

var _config = GutConfig.new()
var _config_gui = null
var _gut_runner = GutRunnerScene.instantiate()
var _has_connected = false
var _tree_root : TreeItem = null

var _tree_scripts = {}

@onready var _ctrls = {
	run_tests_button = $VBox/RunTests,
	run_selected = $VBox/RunSelected,
	test_tree = $VBox/Tabs/Tests,
	settings_vbox = $VBox/Tabs/SettingsScroll/Settings,
	tabs = $VBox/Tabs,
	bg = $Bg
}

@export var bg_color : Color = Color(.36, .36, .36) :
	get: return bg_color
	set(val):
		bg_color = val
		$Bg.color = bg_color


func _ready():
	if Engine.is_editor_hint():
		return
		
	_ctrls.tabs.set_tab_title(0, 'Tests')
	_ctrls.tabs.set_tab_title(1, 'Settings')
	
	_config_gui = GutConfigGui.new(_ctrls.settings_vbox)
	
	_ctrls.test_tree.hide_root = true
	# Stop tests from kicking off when the runner is "ready" and
	# prevents it from writing results file that is used by
	# the panel.
	_gut_runner.set_cmdln_mode(true)
	add_child(_gut_runner)
	
	# Becuase of the janky _utils psuedo-global script, we cannot
	# do all this in _ready.  If we do this in _ready, it generates
	# a bunch of errors.  The errors don't matter, but it looks bad.
	call_deferred('_post_ready')


func _draw():
	if Engine.is_editor_hint():
		return
		
	var gut = _gut_runner.get_gut()
	if(!gut.is_running()):
		var r = Rect2(Vector2(0, 0), get_rect().size)
		draw_rect(r, Color.BLACK, false, 2)


func _post_ready():
	var gut = _gut_runner.get_gut()
	gut.start_run.connect(_on_gut_run_started)
	gut.end_run.connect(_on_gut_run_ended)
	_refresh_tree_and_settings()
		

func _set_meta_for_tree_item(item, script, test=null):
	var meta = {
		script = script.path,
		inner_class = script.inner_class_name,
		test = ''
	}
	
	if(test != null):
		meta.test = test.name
		
	item.set_metadata(0, meta)


func _get_script_tree_item(script):
	var to_return : TreeItem = null
	if(_tree_scripts.has(script.path)):
		to_return = _tree_scripts[script.path]
	else:
		to_return = _ctrls.test_tree.create_item(_tree_root)
		to_return.set_text(0, script.path)
		_tree_scripts[script.path] = to_return
	
	_set_meta_for_tree_item(to_return, script)
	return to_return


func _populate_tree():
	var tree : Tree = _ctrls.test_tree
	
	tree.clear()
	_tree_root = _ctrls.test_tree.create_item()

	var scripts = _gut_runner.get_gut().get_test_collector().scripts
	for script in scripts:
		var item = _get_script_tree_item(script)
		if(script.inner_class_name != ''):
			var inner_item = tree.create_item(item)
			inner_item.set_text(0, script.inner_class_name)
			_set_meta_for_tree_item(inner_item, script)
			item = inner_item
			
		for test in script.tests:
			var test_item = tree.create_item(item)
			test_item.set_text(0, test.name)
			_set_meta_for_tree_item(test_item, script, test)
	
	_tree_root.set_collapsed_recursive(true)
	_tree_root.set_collapsed(false)


func _run_all():
	_config.options.selected = ''
	_config.options.inner_class_name = ''
	_config.options.unit_test_name = ''
	run_tests()


func _run_selected():
	var sel_item = _ctrls.test_tree.get_selected()
	if(sel_item == null):
		return
		
	var meta = sel_item.get_metadata(0)
	_config.options.selected = meta.script.get_file()
	_config.options.inner_class_name = meta.inner_class
	_config.options.unit_test_name = meta.test
	run_tests()

func _refresh_tree_and_settings():
	if(_config.options.has('panel_options')):
		_config_gui.set_options(_config.options)
	_config.config_gut(_gut_runner.get_gut())
	_gut_runner.set_gut_config(_config)
	_populate_tree()

# ---------------------------
# Events
# ---------------------------
func _on_gut_run_started():
	_ctrls.run_tests_button.disabled = true
	_ctrls.run_selected.visible = false
	_ctrls.tabs.visible = false
	_ctrls.bg.visible = false
	_ctrls.run_tests_button.text = 'Running'
	queue_redraw()


func _on_gut_run_ended():
	_ctrls.run_tests_button.disabled = false
	_ctrls.run_selected.visible = true
	_ctrls.tabs.visible = true
	_ctrls.bg.visible = true
	_ctrls.run_tests_button.text = 'Run All'
	queue_redraw()


func _on_run_tests_pressed():
	_run_all()


func _on_run_selected_pressed():
	_run_selected()
	
	
func _on_tests_item_activated():
	_run_selected()

# ---------------------------
# Public 
# ---------------------------
func get_gut():
	return _gut_runner.get_gut()

	
func get_config():
	return _config

	
func run_tests():
	# apply the config
	_config.options = _config_gui.get_options(_config.options)
	_gut_runner.set_gut_config(_config)
	_gut_runner.run_tests()
	

func load_config_file(path):
	_config.load_panel_options(path)
	_config.options.selected = ''
	_config.options.inner_class_name = ''
	_config.options.unit_test_name = ''
	
