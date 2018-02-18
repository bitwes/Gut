extends "res://addons/gut/test.gd"

func test_print_indent():
    gut.p('one')
    gut.p('two', 1, 2)
    gut.p('three', 1, 3)
    gut.p('four', 1, 4)

func test_print_non_strings():
    gut.p([1, 2, 3])
    gut.p(Node2D.new())

func test_print_multiple_lines():
    var lines = "hello\nworld\nhow\nare\nyou?"
    gut.p(lines)
