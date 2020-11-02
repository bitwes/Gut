extends Node2D
# ##############################################################################
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
# ##############################################################################

# ##############################################################################
# Description:
# ------------
# This file is used to illustrate a couple ways of loading scripts and running
# them.  This is also the method used to execute the tests of the Gut object
# itself.
#
# The Gut object in the scene has already been configured through the editor
# to load up various scripts.  You can experiment with the settings in the
# scene or edit the code in this script.
# ##############################################################################

var tester = null

func _ready():
	# DO NOTHING HERE, connect to gut_ready instead.
	pass

func _on_Gut_gut_ready():
	#$Gut.export_if_tests_found()
	#$Gut.import_tests_if_none_found()

	# This line makes Gut use the export_path to load up the exported list
	# of tests if it didn't find any tests.  This will occur after it has tried
	# to load up all the configured directories.
	#
	# Using this line, you won't have to do anything to your test scene when
	# running after being exported.
	#
	# You must have set export_path on the Gut object, exported your tests, and
	# changed your project's export settings to include whatever file extension
	# you gave your export file name.
#	$Gut.import_tests_if_none_found()

	# -----
	# Uncomment these lines to see various behaviors
	# -----
	#_run_test_one_line()
	#_run_gut_tests(get_node('Gut'))
	#_run_all_tests()
	pass

# Show that the signal is working.
func _on_tests_finished():
	tester.p("Tests done callback called")

#------------------------------------
# Example:
# This creates an instance of Gut and runs a single script.  The output will
# be visible in the console, not the Gut instance on the screen.
#------------------------------------
func _run_test_one_line():
	load('res://addons/gut/gut.gd').new().test_script('res://test/samples/test_sample_all_passed.gd')

#------------------------------------
# Example:
# More lines, get result text out manually.  Can also inspect the results further
# with a reference to the class.
#------------------------------------
func _run_all_tests():
	# get an instance of gut
	tester = get_node("Gut")

	tester.connect('tests_finished', self, '_on_tests_finished')
	tester.show()
	tester.set_position(Vector2(100, 100))

	tester.set_should_print_to_console(true)

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
	tester.test_scripts(true)

	# Insepect the results, put out some more text conditionally.
	if(tester.get_fail_count() > 0):
		tester.p("SOMEBODY BROKE SOMETHIN'!!\n")

# These are all the tests that MUST be run to verify Gut is working as expected.
# Some methods may include tests that are expected to fail.  Closely inspect
# the resutls.
func _run_gut_tests(gut):
	gut.set_should_print_to_console(false)
	gut.add_script('res://test/unit/test_doubler.gd')
	gut.add_script('res://test/unit/test_gut_yielding.gd')
	gut.add_script('res://test/unit/test_gut.gd')
	gut.add_script('res://test/unit/test_signal_watcher.gd')
	gut.add_script('res://test/unit/test_spy.gd')
	gut.add_script('res://test/unit/test_stubber.gd')
	gut.add_script('res://test/unit/test_summary.gd')
	gut.add_script('res://test/unit/test_test_collector.gd')
	gut.add_script('res://test/unit/test_test.gd')

	gut.add_script('res://test/integration/test_test_stubber_doubler.gd')
	gut.add_script('res://test/integration/test_doubler_and_stubber.gd')
	gut.add_script('res://test/integration/test_gut_and_stubber.gd')
	gut.add_script('res://test/integration/test_doubler_and_spy.gd')
	gut.add_script('res://test/integration/test_gut_and_spy.gd')

	gut.set_yield_between_tests(true)
	# true says to run all the scripts, not just the first or
	# the selected script.
	gut.test_scripts()

# Make a new Gut and run all the Gut specific tests.
func _on_RunGutTestsButton_pressed():
	var gut = load('res://addons/gut/gut.gd').new()
	add_child(gut)
	gut.set_position(Vector2(0, 0))
	_run_gut_tests(gut)

func _on_ExportTests_pressed():
	$Gut.export_tests()


