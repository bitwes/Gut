extends Node2D
################################################################################
#The MIT License (MIT)
#=====================
#
#Copyright (c) 2015 Tom "Butch" Wesley
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
################################################################################

# ##############################################################################
# This is a template script to be used as the root script for a scene.  The
# gut_main.scn scene is already wired up to use this script.  If you use the
# same directory structure then you can copy these to  your project.
#
# With gut.gd in the res://test/gut directory and your unit tests in
# res://test/unit this script will load up all the tests and run them.
# ##############################################################################
var tester = null

func _ready():
	_run_tests()

func _run_tests():
	tester = load('res://test/gut/gut.gd').new()
	add_child(tester)
	tester.show()
	tester.set_pos(Vector2(100, 100))

	tester.set_should_print_to_console(true)
	tester.set_yield_between_tests(true)
	tester.add_directory('res://test/unit')
	tester.test_scripts()
