extends "res://addons/gut/test.gd"

var Stubber = load('res://addons/gut/stubber.gd')
var Gut = load('res://addons/gut/gut.gd')

var gr = {
	stubber = null,
	gut = null
}

func setup():
	pass

func test_something():
	pending()
