################################################################################
#(G)odot (U)nit (T)est class
#
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
# View readme for usage details.
#
# Version 4.0.0
################################################################################
# Class that all test scripts must extend.
#
# Once a class extends this class it sent (via the numerous script loading
# methods) to a Gut object to run the tests.
################################################################################

extends Node
# constant for signal when calling yeild_for
const YIELD = 'timeout'
#Need a reference to the instance that is running the tests.  This
#is set by the gut class when it runs the tests.  This gets you
#access to the asserts in the tests you write.
var gut = null

# #######################
# Virtual Methods
# #######################
#Overridable method that runs before each test.
func setup():
	pass

#Overridable method that runs after each test
func teardown():
	pass

#Overridable method that runs before any tests are run
func prerun_setup():
	pass

#Overridable method that runs after all tests are run
func postrun_teardown():
	pass

# #######################
# Convenience Methods
# #######################
# see gut method
func assert_eq(got, expected, text=""):
	gut.assert_eq(got, expected, text)

# see gut method
func assert_ne(got, not_expected, text=""):
	gut.assert_ne(got, not_expected, text)

# see gut method
func assert_gt(got, expected, text=""):
	gut.assert_gt(got, expected, text)

# see gut method
func assert_lt(got, expected, text=""):
	gut.assert_lt(got, expected, text)

# see gut method
func assert_true(got, text=""):
	gut.assert_true(got, text)

# see gut method
func assert_false(got, text=""):
	gut.assert_false(got, text)

# see gut method
func assert_between(got, expect_low, expect_high, text=""):
	gut.assert_between(got, expect_low, expect_high, text)

# see gut method
func assert_file_exists(file_path):
	gut.assert_file_exists(file_path)

# see gut method
func assert_file_does_not_exist(file_path):
	gut.assert_file_does_not_exist(file_path)

# see gut method
func assert_file_empty(file_path):
	gut.assert_file_empty(file_path)

# see gut method
func assert_file_not_empty(file_path):
	gut.assert_file_not_empty(file_path)

# see gut method
func assert_get_set_methods(obj, property, default, set_to):
	gut.assert_get_set_methods(obj, property, default, set_to)

func assert_has(obj, element, text=""):
	gut.assert_has(obj, element, text)

func assert_does_not_have(obj, element, text=""):
	gut.assert_does_not_have(obj, element, text)

# see gut method
func pending(text=""):
	gut.pending(text)

# I think this reads better than set_yield_time, but don't want to break anything
func yield_for(time, msg=''):
	return gut.set_yield_time(time, msg)

func end_test():
	gut.end_yielded_test()
