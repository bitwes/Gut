extends Node2D

var GutRunner = load('res://addons/gut/gui/GutRunner.tscn')

var _runner = GutRunner.instantiate()

func _init():
	_runner.auto_run_tests = false

func _ready():
	add_child(_runner)
	print(_runner.get_gut())
	
