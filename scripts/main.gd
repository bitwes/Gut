extends Node2D

func _ready():
	#------------------------------------
	#One line, print to console
	#------------------------------------
	load('res://scripts/gut.gd').new().test_script('res://scripts/sample_tests.gd')

	
	#------------------------------------
	#More lines, get result text out manually.  Can also inspect the results further 
	#with a reference to the class.
	#------------------------------------	
	#get an instance of gut
	var tester = load('res://scripts/gut.gd').new()
	add_child(tester)
	#stop it from printing to console
	tester.set_should_print_to_console(false)
	#change the log level to more detail
	#tester.set_log_level(0)#tester.LOG_LEVEL_ALL_ASSERTS)
	tester.test_script('res://scripts/another_sample.gd')
	#test the script
	tester.add_script('res://scripts/sample_tests.gd')
	tester.add_script('res://scripts/another_sample.gd')
	tester.add_script('res://scripts/all_passed.gd')
	tester.add_script('res://scripts/gut_tests.gd')
	tester.test_scripts()
	#get the results out and send them to a text box
	print(tester.get_result_text())
	#Insepect the results, put out some more text conditionally.
	if(tester.get_fail_count() > 0):
		tester.p("SOMEBODY BROKE SOMETHIN'!!\n")
	
