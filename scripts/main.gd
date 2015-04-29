extends Node2D

func _ready():
	_run_all_tests()


func _run_test_one_line():
#------------------------------------
#One line, print to console
#------------------------------------
	load('res://scripts/gut.gd').new().test_script('res://scripts/sample_tests.gd')

func _run_all_tests():
#------------------------------------
#More lines, get result text out manually.  Can also inspect the results further 
#with a reference to the class.
#------------------------------------
	#get an instance of gut
	var tester = load('res://scripts/gut.gd').new()
	#add as a child so you can see the GUI when run
	add_child(tester)
	tester.show()
	tester.set_pos(Vector2(100, 100))
	
	#stop it from printing to console, just because we can
	tester.set_should_print_to_console(false)
	
	#Run a single test script, this will not appear in the drop
	#down in the display, but the first time it runs it will
	#display the results.
	tester.p("This is a one time script, notice it's not in the drop down")
	#tester.test_script('res://scripts/another_sample.gd')
	
	#Add a bunch of test scripts to run.  These will appear in the drop
	#down and can be rerun.  As long as you don't introduce a runtime
	#error, you can leave it running, code some more, then rerun the
	#tests for any or all of the scripts that have been added using
	#add_script.
	
	# !! --------
	#Set the yield between tests so that tests print as they complete
	#instead of having to wait until the end.  Not compatible with
	#1.0 so disabled by default.
	#tester.set_yield_between_tests(true) 
	# !! --------
	tester.add_script('res://scripts/gut_tests.gd', true)
	tester.add_script('res://scripts/test_that_take_awhile.gd')
	tester.add_script('res://scripts/test_gut_yielding.gd')
	tester.add_script('res://scripts/sample_tests.gd')
	tester.add_script('res://scripts/another_sample.gd')
	tester.add_script('res://scripts/all_passed.gd')
	tester.add_script('res://script_does_not_exist.gd')
	tester.test_scripts()

	#get the results to the console, just to show you can get them
	#out at the end of the process.
	print(tester.get_result_text())
	
	#Insepect the results, put out some more text conditionally.
	if(tester.get_fail_count() > 0):
		tester.p("SOMEBODY BROKE SOMETHIN'!!\n")
	

func _run_gut_tests():
	var tester = load('res://scripts/gut.gd').new()
	add_child(tester)
	
	tester.set_should_print_to_console(false)
	tester.add_script('res://scripts/gut_tests.gd')
	tester.add_script('res://scripts/all_passed.gd')
	tester.test_scripts()
