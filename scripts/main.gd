extends Node2D

func _ready():
	#will be used later to print results to
	var text_box = TextEdit.new()
	text_box.set_size(Vector2(800, 600))
	text_box.set_pos(Vector2(0, 0))
	add_child(text_box)
	
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
	#stop it from printing to console
	tester.set_should_print(false)
	#change the log level to more detail
	tester.set_log_level(tester.LOG_LEVEL_ALL_ASSERTS)
	#test the script
	tester.test_script('res://scripts/sample_tests.gd')
	#get the results out and send them to a text box
	text_box.insert_text_at_cursor(tester.get_result_text())
	#Insepect the results, put out some more text conditionally.
	if(tester.get_fail_count() > 0):
		text_box.insert_text_at_cursor("SOMEBODY BROKE SOMETHIN'!!\n")
	
	#You can alter the log level after the tests have run, and get different info out
	text_box.insert_text_at_cursor("\n\n************FAIL ONLY****************\n")
	tester.set_log_level(tester.LOG_LEVEL_FAIL_ONLY)
	text_box.insert_text_at_cursor(tester.get_result_text())
	
	#Do it again, do it again!!
	text_box.insert_text_at_cursor("\n\n************TEST AND FAILURES****************\n")
	tester.set_log_level(tester.LOG_LEVEL_TEST_AND_FAILURES)
	text_box.insert_text_at_cursor(tester.get_result_text())
	