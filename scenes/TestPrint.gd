extends Node2D

var _lgr = null
var _gut = null

func _on_Gut_gut_ready():
	_lgr = load('res://addons/gut/logger.gd').new()
	
	#$Gut.get_gut().get_gui().set_font_size(30)
	_gut = $Gut.get_gut()
	_gut.add_directory('res://test/samples')
	_gut.set_logger(_lgr)
	_gut.maximize()

	_lgr.disable_printer('console', false)
	_print_some_things()
	_print_all_formats()

	_lgr.log()
	_lgr.log()
	_lgr.set_indent_level(3)
	_lgr.set_indent_string('|...')
	_print_some_things()
	_print_all_formats()

	_lgr.set_indent_level(0)
	_lgr.set_indent_string('    ')

func _print_some_things():
	_lgr.log('Hello World')
	_lgr.passed('This passed')
	_lgr.failed('This failed')
	_lgr.info('infoing')
	_lgr.warn('warning')
	_lgr.error('erroring')
	_lgr.pending('pending')
	_lgr.pending('')
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

