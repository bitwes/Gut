
# Creating Tests

## Sample for Setup
Here's a sample test script.  Copy the contents into the file `res://test/unit/test_example.gd` then run your scene.  If everything is setup correctly then you'll see some passing and failing tests.  If you don't have "Run on Load" checked in the editor, you'll have to hit the ">" button on the dialog window.

``` gdscript
extends GutTest

func before_all():
	gut.p("Before All", 2)

func before_each():
	gut.p("Before Each", 2)

func after_each():
	gut.p("After Each", 2)

func after_all():
	gut.p("After All", 2)

func test_assert_eq_number_not_equal():
	assert_eq(1, 2, "Should fail.  1 != 2")

func test_assert_eq_number_equal():
	assert_eq('asdf', 'asdf', "Should pass")

func test_assert_true_with_true():
	assert_true(true, "Should pass, true is true")

func test_assert_true_with_false():
	assert_true(false, "Should fail")

func test_something_else():
	assert_true(false, "didn't work")
```

## Test Script
All test scripts must extend the test class.
* `extends GutTest`

Each test script has optional setup and teardown methods that you can provide an implementation for.  These are called by Gut at various stages of execution.  They take no parameters.
 * `before_all()`:  Runs once before any test is ran.
 * `before_each()`:  Runs before each test.
 * `after_each()`:  Runs after each test.
 * `after_all()`:  Runs once after all tests finish running.

All tests in the test script must start with the prefix `test_` in order for them to be run.  The methods must not have any parameters.
* `func test_this_is_only_a_test():`

Each test should perform at least one assert or call `pending` to indicate the test hasn't been implemented yet.

A list of all `asserts` and other helper functions available in your test script can be found in [Methods](Asserts-And-Methods).  There's also some helpful methods in the Gut object itself.  They are listed in [Gut Settings and Methods](Gut-Settings-And-Methods)

## Inner Test Classes
You can group tests together using Inner Classes. These classes must start with the prefix `'Test'` (this is configurable) and they must also extend `GutTest`.  You cannot create Inner Test Classes inside Inner Test Classes.  More info can be found at [Inner Test Classes](Inner-Test-Classes).

## Simple Example
```
extends GutTest

class TestFeatureA:
	extends GutTest

	var Obj = load('res://scripts/object.gd')
	var _obj = null

	func before_each():
		_obj = Obj.new()

	func test_something():
		assert_true(_obj.is_something_cool(), 'Should be cool.')

class TestFeatureB:
	extends GutTest

	var Obj = load('res://scripts/object.gd')
	var _obj = null

	func before_each():
		_obj = Obj.new()

	func test_foobar():
		assert_eq(_obj.foo(), 'bar', 'Foo should return bar')
```
## Where to next?
* [Gut Settings and Methods](Gut-Settings-And-Methods)
* [Inner Test Classes](Inner-Test-Classes)
* [Methods](Methods)
* [Command Line](Command-Line)
* [Simulate](Simulate)
* [Yielding during tests](Yielding)