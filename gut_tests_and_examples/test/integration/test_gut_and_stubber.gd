extends "res://addons/gut/test.gd"

var Gut = load('res://addons/gut/gut.gd')
var Test = load('res://addons/gut/test.gd')

var gr = {
    gut = null
}

func setup():
    pass

func test_can_get_stubber():
    var g = Gut.new()
    assert_ne(g.get_stubber(), null)

# ---------------------------------
# these two tests use the gut instance that is passed to THIS test.  This isn't
# PURE testing but it appears to cover the bases ok.
func test_stubber_cleared_between_tests_part1():
    gut.get_stubber().set_return('thing', 'method', 5)
    gut.p('this sets up for next test')

func test_stubber_cleared_between_tests_part2():
    assert_eq(gut.get_stubber().get_return('thing', 'method'), null)
# ---------------------------------


func test_can_get_doubler():
    var g = Gut.new()
    assert_ne(g.get_doubler(), null)

func test_doublers_stubber_is_guts_stubber():
    var g = Gut.new()
    assert_eq(g.get_doubler().get_stubber(), g.get_stubber())
