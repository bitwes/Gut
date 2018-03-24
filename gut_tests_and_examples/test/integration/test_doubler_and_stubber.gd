extends "res://addons/gut/test.gd"

var Doubler = load('res://addons/gut/doubler.gd')
var Stubber = load('res://addons/gut/stubber.gd')

var gr = {
    doubler = null,
    stubber = null
}

func setup():
    gr.doubler = Doubler.new()
    gr.stubber = Stubber.new()

func test_pending():
    pending()
