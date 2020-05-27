extends Node2D

var _lgr = null

func _on_Gut_gut_ready():
	_lgr = load('res://addons/gut/logger.gd').new()
	$Gut.get_gut().set_logger(_lgr)
	$Gut.get_gut().maximize()

	_lgr.disable_printer('console', false)
	_print_some_things()
	_print_all_formats()

	_lgr.log()
	_lgr.log()
	_lgr.set_indent_level(3)
	_lgr.set_indent_string('|...')
	_print_some_things()
	_print_all_formats()

func _print_some_things():
	_lgr.log('Hello World')
	_lgr.passed('This passed')
	_lgr.failed('This failed')
	_lgr.info('infoing')
	_lgr.warn('warning')
	_lgr.error('erroring')
	_lgr.deprecated('you do not need this anymore')
	_lgr.deprecated('deprecated', 'use me')
	_lgr.log()
	_lgr.log()

func _print_all_formats():
	for key in _lgr.fmts:
		_lgr.lograw(key, _lgr.fmts[key])
		_lgr.lograw(' ')
	_lgr.log()

	_lgr.lograw(_lgr.get_indent_text())
	for key in _lgr.fmts:
		_lgr.lograw(key, _lgr.fmts[key])
		_lgr.lograw(' ')
	_lgr.log()

	for key in _lgr.fmts:
		_lgr.log(key, _lgr.fmts[key])
