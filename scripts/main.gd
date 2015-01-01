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
	tester.set_log_level(tester.LOG_LEVEL_ALL_ASSERTS)
	#test the script
	tester.test_script('res://scripts/sample_tests.gd')
	#get the results out and send them to a text box
	print(tester.get_result_text())
	#Insepect the results, put out some more text conditionally.
	if(tester.get_fail_count() > 0):
		print("SOMEBODY BROKE SOMETHIN'!!\n")
	
