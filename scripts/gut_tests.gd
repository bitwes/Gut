extends "res://scripts/gut.gd".Tests

var counts = {
	setup_count = 0,
	teardown_count = 0,
	prerun_setup_count = 0,
	postrun_teardown_count = 0,
	should_fail = 0
}

#Used to count the number of tests that should fail so that they
#can be compared at the end.
func should_fail():
	counts.should_fail += 1

func setup():
	counts.setup_count += 1

func teardown():
	counts.teardown_count += 1

func prerun_setup():
	counts.prerun_setup_count += 1

func postrun_teardown():
	counts.postrun_teardown_count += 1
	#can't verify that this ran, so do an assert.
	#Asserts in any of the setup/teardown methods
	#is a bad idea in general.
	gut.assert_true(true, 'POSTTEARDOWN RAN')


#------------------------------
#Number tests
#------------------------------

func test_assert_eq_number_not_equal():
	should_fail()
	gut.assert_eq(1, 2, "Should fail.  1 != 2")
	
func test_assert_eq_number_equal():
	gut.assert_eq('asdf', 'asdf', "Should pass")

func test_assert_ne_number_not_equal():
	gut.assert_ne(1, 2, "Should pass, 1 != 2")

func test_assert_ne_number_equal():
	should_fail()
	gut.assert_ne(1, 1, "Should fail")

func test_assert_gt_number_with_gt():
	gut.assert_gt(1, 2, "Should Pass")

func test_assert_gt_number_with_lt():
	should_fail()
	gut.assert_gt(2, 1, "Should fail")

func test_assert_lt_number_with_lt():
	gut.assert_lt(2, 1, "Should Pass")

func test_assert_lt_number_with_gt():
	should_fail()
	gut.assert_lt(1, 2, "Should fail")

#------------------------------
#string tests
#------------------------------

func test_assert_eq_string_not_equal():
	should_fail()
	gut.assert_eq("one", "two", "Should Fail")

func test_assert_eq_string_equal():
	gut.assert_eq("one", "one", "Should Pass")

func test_assert_ne_string_not_equal():
	gut.assert_ne("one", "two", "Should Pass")

func test_assert_ne_string_equal():
	should_fail()
	gut.assert_ne("one", "one", "Should Fail")

func test_assert_gt_string_with_gt():
	gut.assert_gt("a", "b", "Should Pass")

func test_assert_gt_string_with_lt():
	should_fail()
	gut.assert_gt("b", "a", "Sould Fail")

func test_assert_lt_string_with_lt():
	gut.assert_lt("b", "a", "Should Pass")

func test_assert_lt_string_with_gt():
	should_fail()
	gut.assert_lt("a", "b", "Should Fail")
#------------------------------
#boolean tests
#------------------------------
func test_assert_true_with_true():
	gut.assert_true(true, "Should pass, true is true")

func test_assert_true_with_false():
	should_fail()
	gut.assert_true(false, "Should fail")

func test_assert_flase_with_true():
	should_fail()
	gut.assert_false(true, "Should fail")

func test_assert_false_with_false():
	gut.assert_false(false, "Should pass")

#------------------------------
#Misc tests
#------------------------------
func test_can_call_eq_without_text():
	gut.assert_eq(1, 1)

func test_can_call_ne_without_text():
	gut.assert_ne(1, 2)

func test_can_call_true_without_text():
	gut.assert_true(true)

func test_can_call_false_without_text():
	gut.assert_false(false)

func test_verify_results():
	gut.p("/*THESE SHOULD ALL PASS, IF NOT THEN SOMETHING IS BROKEN*/")
	gut.assert_eq(counts.should_fail, gut.get_fail_count(), "The expected number of tests should have failed.")
	gut.assert_eq(1, counts.prerun_setup_count, "Prerun setup should have been called once")
	gut.assert_eq(gut.get_test_count(), counts.setup_count, "Setup should have been called for the number of tests ran")
	gut.assert_eq(gut.get_test_count() -1, counts.teardown_count, "Teardown should have been called one less time")
	