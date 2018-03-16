# ------------------------------------------------------------------------------
# These tests are used to manually verify that the message about "moved"
# methods is displayed.  Moved methods were part of a refactoring that moved
# various methods from the Gut object to the Test object.
# ------------------------------------------------------------------------------
extends "res://addons/gut/test.gd"

func prerun_setup():
	gut.p("""
!!! These tests are used to veify the output when a test includes a call to a
!!! moved assert.  These tests will all fail.
""")

# #############
# Tests
# #############
func test_assert_eq_pass():
	gut.assert_eq(1, 1)

func test_assert_eq_fail():
	gut.assert_eq(1, 2)

func test_assert_true_pass():
	gut.assert_true(true)

func test_assert_true_fail():
	gut.assert_true(false)
