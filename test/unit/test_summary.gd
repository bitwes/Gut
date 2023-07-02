extends "res://addons/gut/test.gd"

var Summary = load('res://addons/gut/test_collector.gd')
var TestCollector = load('res://addons/gut/test_collector.gd')

# Summary now just prints stuff and doesn't have much logic.  I removed all the
# old tests that do not apply anymore, but kept this as a home for any future
# tests.

func test_can_make_one():
    var s = Summary.new()
    assert_not_null(s)

func test_can_make_one_with_a_test_colletor():
    var s = Summary.new(TestCollector.new())
    assert_not_null(s)