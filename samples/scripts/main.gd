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

################################################################################
# Description:
# ------------
# This file is used to illustrate a couple ways of loading scripts and running
# them.  This is also the method used to execute the tests of the Gut object
# itself.
################################################################################

var tester = null

func _ready():
	#_run_test_one_line():
	#_run_gut_tests()
	#_run_all_tests()
	pass

# Show that the signal is working.
func _on_tests_finished():
	tester.p("Tests done callback called")

#------------------------------------
# One line, print to console
#------------------------------------
func _run_test_one_line():
	load('res://addons/gut/gut.gd').new().test_script('res://test/unit/sample_tests.gd')

#------------------------------------
# More lines, get result text out manually.  Can also inspect the results further 
# with a reference to the class.
#------------------------------------
func _run_all_tests():
	# get an instance of gut
	tester = get_node("Gut")
	
	tester.connect('tests_finished', self, '_on_tests_finished')
	tester.show()
	tester.set_pos(Vector2(100, 100))
	
	tester.set_should_print_to_console(true)
	
	# Run a single test script, this will not appear in the drop
	# down in the display, but the first time it runs it will
	# display the results.
	
	tester.test_script('res://test_dir_load/test_samples3.gd')
	tester.p("This is the results of running a single script.  Notice it's not in the drop down")
	
	# !! --------
	# Set the yield between tests so that tests print as they complete
	# instead of having to wait until the end.  It's a little slower,
	# but you can tell what's going on.  Because it's slower it's
	# disabled by default.
	tester.set_yield_between_tests(true) 
	# !! --------
	
	# Add all scripts in two directories.
	tester.add_directory('res://test/unit')
	tester.add_directory('res://test/integration')
	
	# Automatcially run all scripts when loaded.
	tester.test_scripts()
	
	# Insepect the results, put out some more text conditionally.
	if(tester.get_fail_count() > 0):
		tester.p("SOMEBODY BROKE SOMETHIN'!!\n")
	
func _run_gut_tests():
	tester = get_node("Gut")
	
	tester.set_should_print_to_console(false)
	tester.add_script('res://test/unit/test_gut.gd')
	tester.add_script('res://test/unit/test_gut_yielding.gd')
	tester.set_yield_between_tests(true)
	
	