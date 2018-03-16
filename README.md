# Gut 6.1.0
GUT (Godot Unit Test) is a utility for writing tests for your Godot Engine game.  It allows you to write tests for your gdscript in gdscript.

### Godot 3.0 Compatible.
Version 6.0.0 is Godot 3.0 compatible.  These changes are not compatible with any of the 2.x versions of Godot.  The godot_2x branch has been created to hold the old version of Gut that works with Godot 2.x.  Barring any severe issues, there will not be any more development for Godot 2.x.

# License
Gut is provided under the MIT license.  [The license is distributed with Gut so it is in the `addons/gut` folder](addons/gut/LICENSE.md).  I also didn't want the Gut license to accidentally be copied into another project's root directory when installed through the Godot Asset Library.

# Method Links
<table><tr>
<td>

[assert_between](#assert_between)<br/>
[assert_does_not_have](#assert_does_not_have)<br/>
[assert_eq](#assert_eq)<br/>
[assert_extends](#assert_extends)<br/>
[assert_false](#assert_false)<br/>
[assert_file_does_not_exist](#assert_file_does_not_exist)<br/>
[assert_file_empty](#assert_file_empty)<br/>
[assert_file_exists](#assert_file_exists)<br/>
[assert_file_not_empty](#assert_file_not_empty)<br/>
[assert_get_set_methods](#assert_get_set_methods)<br/>
[assert_gt](#assert_gt)<br/>
[assert_has_signal](#assert_has_signal)<br/>

</td><td>

[assert_has](#assert_has)<br/>
[assert_lt](#assert_lt)<br/>
[assert_ne](#assert_ne)<br/>
[assert_signal_emit_count](#assert_signal_emit_count)<br/>
[assert_signal_emitted_with_parameters](#assert_signal_emitted_with_parameters)<br/>
[assert_signal_emitted](#assert_signal_emitted)<br/>
[assert_signal_not_emitted](#assert_signal_not_emitted)<br/>
[assert_true](#assert_true)<br/>
[get_signal_emit_count](#get_signal_emit_count)<br/>
[get_signal_parameters](#get_signal_parameters)<br/>
[watch_signals](#watch_signals)<br/>

</td>
</tr></table>

# Table of Contents
1.  [Install](#install)
1.  [Gut Settings](#gut_settings)
1.  [Creating Tests](#creating_tests)
1.  [Test Related Methods](#method_list)
1.  [Methods for Configuring Test Execution](#gut_methods)
1.  [Extras](#extras)
	1.  [Strict Type Checking](#strict)
	1.  [File Manipulation](#files)
	1.  [Watching Tests](#watch)
	1.  [Output Detail](#output_detail)
	1.  [Printing](#printing)
1. [Advanced](#advanced)
	1.  [Simulate](#simulate)
	1.  [Yielding](#yielding)
1. [Command Line Interface](#command_line)
1. [Contributing](#contributing)

# <a name="install"> Install
## Installing from Download
Download and extract the zip from the [releases](https://github.com/bitwes/gut/releases) or from the [Godot Asset Library](https://godotengine.org/asset-library/asset/54).  

Extract the zip and place the `gut` directory into your `addons` directory in your project.  If you don't have an `addons` folder at the root of your project, then make one and THEN put the `gut` directory in there.

## Installing from in-editor Godot Asset Lib
1.  Click the AssetLib button at the top of the editor
1.  Search for "Gut"
1.  Click it.
1.  Click "Install".  This will kick off the download.
1.  Click the 2nd "Install" button that appears when the download finishes.  It will be in a little dialog at the bottom of the AssetLib window.
1.  This part is IMPORTANT.  You only need the `addons/gut` directory.  So make sure that directory is checked then uncheck anything that isn't in the `addons/gut` directory.
1.  Click the 3rd "Install" button.
1.  You did it!

## New Install Setup
From the menu choose Scene->Project Settings, click the plugins tab and activate Gut.

The next few steps cover the suggested configuration.  Feel free to deviate where you see fit.

1.  Create directories to store your tests and test related code
	* `res://test`
	* `res://test/unit`
	* `res://test/integration`
1.  Create a scene that will use Gut to run your tests at `res://test/tests.tscn`
	* Add a Gut object the same way you would any other object.
	* Click "Add/Create Node"
	* type "Gut"
	* press enter.
1.  Configure Gut to find your tests.  Select it in the Scene Tree and set the following settings in the Inspector:
	* In the `Directory1` setting enter `res://test/unit`
	* In the `Directory2` setting enter `res://test/integration`

That's it.  The next step is to make some tests.

# <a name="gut_settings"> Gut Settings
The following settings are accessible in the Editor under "Script Variables"

* <b>Run On Load</b>:  Flag to indicate if Gut should start running tests when loaded.
* <b>Select Script</b>:  Select the named script in the drop down.  When this is set and "Run On Load" is true, only this script will be run.
* <b>Tests Like</b>:  Only tests that contain the set text will be run initially.
* <b>Should Print To Console</b>:  Print output to the console as well as to Gut.
* <b>Log Level</b>:  Set the level of output.
* <b>Yield Between Tests</b>:  A short yield is performed by Gut so that the Gut control has a chance to redraw.  This increases execution time by a tiny bit, but stops Gut from appearing to be hung up while it runs tests.
* <b>Disable Strict Datatype Checks</b>:  Disables the verifying of datatypes before comparisons are done.  You can disable this if you want.  See the section on datatype checks for more details.
* <b>Test Prefix</b>:  The prefix used on all test functions.  This prefixed will be used by Gut to find tests inside your test scripts.
* <b>File Prefix</b>:  The prefix used on all test files.  This is used in conjunction with the Directory settings to find tests.
* <b>File Extension</b>:  This is the suffix it will use to find test files.  
* <b>Directory(1-6)</b>:  The path to the directories where your test scripts are located.  Subdirectories are not included.  If you need more than six directories you can use the `add_directory` method to add more.

# <a name="creating_tests"> Making Tests

## Sample for Setup
Here's a sample test script.  Copy the contents into the file `res://test/unit/test_example.gd` then run your scene.  If everything is setup correctly then you'll see some passing and failing tests.  If you don't have "Run on Load" checked in the editor, you'll have to hit the "Run" button on the dialog window.

``` python
extends "res://addons/gut/test.gd"
func setup():
	gut.p("ran setup", 2)

func teardown():
	gut.p("ran teardown", 2)

func prerun_setup():
	gut.p("ran run setup", 2)

func postrun_teardown():
	gut.p("ran run teardown", 2)

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

## Creating tests
All test scripts must extend the test class.
* `extends "res://addons/gut/test.gd"`

Each test script has optional setup and teardown methods that are called at various stages of execution.  They take no parameters.
 * `setup()`:  Ran before each test
 * `teardown()`:  Ran after each test
 * `prerun_setup()`:  Ran before any test is run
 * `postrun_teardown()`:  Ran after all tests have run

All tests in the test script must start with the prefix `test_` in order for them to be run.  The methods must not have any parameters.
* `func test_this_is_only_a_test():`

Each test should perform at least one assert or call `pending` to indicate the test hasn't been implemented yet.


# <a name="method_list"> Test Related Methods
These methods should be used in tests to make assertions.  These methods are available to anything that inherits from the Test class (`extends "res://addons/gut/test.gd"`).  All sample code listed for the methods can be found here in [test_readme_examples.gd](gut_tests_and_examples/test/samples/test_readme_examples.gd)
#### pending(text="")
flag a test as pending, the optional message is printed in the GUI
``` python
pending('This test is not implemented yet')
pending()
```
#### <a name="assert_eq"> assert_eq(got, expected, text="")
assert got == expected and prints optional text
``` python
var one = 1
var node1 = Node.new()
var node2 = node1

assert_eq(one, 1, 'one should equal one') # PASS
assert_eq('racecar', 'racecar') # PASS
assert_eq(node2, node1) # PASS

gut.p('-- failing --')
assert_eq(1, 2) # FAIL
assert_eq('hello', 'world') # FAIL
assert_eq(self, node1) # FAIL
```
#### <a name="assert_ne"> assert_ne(got, not_expected, text="")
asserts got != expected and prints optional text
``` python
var two = 2
var node1 = Node.new()

gut.p('-- passing --')
assert_ne(two, 1, 'Two should not equal one.')  # PASS
assert_ne('hello', 'world') # PASS
assert_ne(self, node1) # PASS

gut.p('-- failing --')
assert_ne(two, 2) # FAIL
assert_ne('one', 'one') # FAIL
assert_ne('2', 2) # FAIL
```
#### <a name="assert_gt"> assert_gt(got, expected, text="")
assserts got > expected
``` python
var bigger = 5
var smaller = 0

gut.p('-- passing --')
assert_gt(bigger, smaller, 'Bigger should be greater than smaller') # PASS
assert_gt('b', 'a') # PASS
assert_gt('a', 'A') # PASS
assert_gt(1.1, 1) # PASS

gut.p('-- failing --')
assert_gt('a', 'a') # FAIL
assert_gt(1.0, 1) # FAIL
assert_gt(smaller, bigger) # FAIL
```
#### <a name="assert_lt"> assert_lt(got, expected, text="")
asserts got < expected
``` python
var bigger = 5
var smaller = 0
gut.p('-- passing --')
assert_lt(smaller, bigger, 'Smaller should be less than bigger') # PASS
assert_lt('a', 'b') # PASS

gut.p('-- failing --')
assert_lt('z', 'x') # FAIL
assert_lt(-5, -5) # FAIL
```
#### <a name="assert_true"> assert_true(got, text="")
asserts got == true
``` python
gut.p('-- passing --')
assert_true(true, 'True should be true') # PASS
assert_true(5 == 5, 'That expressions should be true') # PASS

gut.p('-- failing --')
assert_true(false) # FAIL
assert_true('a' == 'b') # FAIL
```
#### <a name="assert_false"> assert_false(got, text="")
asserts got == false
``` python
gut.p('-- passing --')
assert_false(false, 'False is false') # PASS
assert_false(1 == 2) # PASS
assert_false('a' == 'z') # PASS
assert_false(self.has_user_signal('nope')) # PASS

gut.p('-- failing --')
assert_false(true) # FAIL
assert_false('ABC' == 'ABC') # FAIL
```
#### <a name="assert_between"> assert_between(got, expect_low, expect_high, text="")
asserts got > expect_low and <= expect_high
``` python
gut.p('-- passing --')
assert_between(5, 0, 10, 'Five should be between 0 and 10') # PASS
assert_between(10, 0, 10) # PASS
assert_between(0, 0, 10) # PASS
assert_between(2.25, 2, 4.0) # PASS

gut.p('-- failing --')
assert_between('a', 'b', 'c') # FAIL
assert_between(1, 5, 10) # FAIL
```
#### <a name="assert_has"> assert_has(obj, element, text='')
Asserts that the object passed in "has" the element.  This works with any object that has a `has` method.
``` python
var an_array = [1, 2, 3, 'four', 'five']
var a_hash = { 'one':1, 'two':2, '3':'three'}

gut.p('-- passing --')
assert_has(an_array, 'four') # PASS
assert_has(an_array, 2) # PASS
# the hash's has method checks indexes not values
assert_has(a_hash, 'one') # PASS
assert_has(a_hash, '3') # PASS

gut.p('-- failing --')
assert_has(an_array, 5) # FAIL
assert_has(an_array, self) # FAIL
assert_has(a_hash, 3) # FAIL
assert_has(a_hash, 'three') # FAIL
```
#### <a name="assert_does_not_have"> assert_does_not_have(obj, element, text='')
The inverse of `assert_has`
``` python
var an_array = [1, 2, 3, 'four', 'five']
var a_hash = { 'one':1, 'two':2, '3':'three'}

gut.p('-- passing --')
assert_does_not_have(an_array, 5) # PASS
assert_does_not_have(an_array, self) # PASS
assert_does_not_have(a_hash, 3) # PASS
assert_does_not_have(a_hash, 'three') # PASS

gut.p('-- failing --')
assert_does_not_have(an_array, 'four') # FAIL
assert_does_not_have(an_array, 2) # FAIL
# the hash's has method checkes indexes not values
assert_does_not_have(a_hash, 'one') # FAIL
assert_does_not_have(a_hash, '3') # FAIL
```

#### <a name="assert_has_signal"> assert_has_signal(object, signal_name)
Asserts the passed in object has a signal with the specified name.  It should be noted that all the asserts that verfy a signal was/wasn't emitted will first check that the object has the signal being asserted against.  If it does not, a specific failure message will be given.  This means you can usually skip the step of specifically verifying that the object has a signal and move on to making sure it emits the signal correctly.
``` python
class SignalObject:
	func _init():
		add_user_signal('some_signal')
		add_user_signal('other_signal')

func test_assert_has_signal():
	var obj = SignalObject.new()

	gut.p('-- passing --')
	assert_has_signal(obj, 'some_signal')
	assert_has_signal(obj, 'other_signal')

	gut.p('-- failing --')
	assert_has_signal(obj, 'not_a real SIGNAL')
	assert_has_signal(obj, 'yea, this one doesnt exist either')
	# Fails because the signal is not a user signal.  Node2D does have the
	# specified signal but it can't be checked this way.  It could be watched
	# and asserted that it fired though.
	assert_has_signal(Node2D.new(), 'exit_tree')

```
#### <a name="watch_signals"> watch_signals(object)
This must be called in order to make assertions based on signals being emitted.  __Right now, this only supports signals that are emitted with 9 or less parameters.__  This can be extended but nine seemed like enough for now.  The Godot documentation suggests that the limit is four but in my testing I found you can pass more.

This must be called in each test in which you want to make signal based assertions in.  You can call it multiple times with different objects.   You should not call it multiple times with the same object in the same test.  The objects that are watched are cleared after each test (specifically right before `teardown` is called).  Under the covers, Gut will connect to all the signals an object has and it will track each time they fire.  You can then use the following asserts and methods to verify things are acting correct.

#### <a name=assert_signal_emitted> assert_signal_emitted(object, signal_name)
Assert that the specified object emitted the named signal.  You must call `watch_signals` and pass it the object that you are making assertions about.  This will fail if the object is not being watched or if the object does not have the specified signal.  Since this will fail if the signal does not exist, you can often skip using `assert_has_signal`.
``` python
class SignalObject:
	func _init():
		add_user_signal('some_signal')
		add_user_signal('other_signal')

func test_assert_signal_emitted():
	var obj = SignalObject.new()

	watch_signals(obj)
	obj.emit_signal('some_signal')

	gut.p('-- passing --')
	assert_signal_emitted(obj, 'some_signal')

	gut.p('-- failing --')
	# Fails with specific message that the object does not have the signal
	assert_signal_emitted(obj, 'signal_does_not_exist')
	# Fails because the object passed is not being watched
	assert_signal_emitted(SignalObject.new(), 'some_signal')
	# Fails because the signal was not emitted
	assert_signal_emitted(obj, 'other_signal')
```
#### <a name="assert_signal_not_emitted"> assert_signal_not_emitted(object, signal_name)
This works opposite of `assert_signal_emitted`.  This will fail if the object is not being watched or if the object does not have the signal.
``` python
class SignalObject:
	func _init():
		add_user_signal('some_signal')
		add_user_signal('other_signal')

func test_assert_signal_not_emitted():
	var obj = SignalObject.new()

	watch_signals(obj)
	obj.emit_signal('some_signal')

	gut.p('-- passing --')
	assert_signal_not_emitted(obj, 'other_signal')

	gut.p('-- failing --')
	# Fails with specific message that the object does not have the signal
	assert_signal_not_emitted(obj, 'signal_does_not_exist')
	# Fails because the object passed is not being watched
	assert_signal_not_emitted(SignalObject.new(), 'some_signal')
	# Fails because the signal was emitted
	assert_signal_not_emitted(obj, 'some_signal')
```
#### <a name="assert_signal_emitted_with_parameters"> assert_signal_emitted_with_parameters(object, signal_name, parameters, index=-1)
Asserts that a signal was fired with the specified parameters.  The expected parameters should be passed in as an array.  An optional index can be passed when a signal has fired more than once.  The default is to retrieve the most recent emission of the signal.

This will fail with specific messages if the object is not being watched or the object does not have the specified signal
``` python
class SignalObject:
	func _init():
		add_user_signal('some_signal')
		add_user_signal('other_signal')

func test_assert_signal_emitted_with_parameters():
	var obj = SignalObject.new()

	watch_signals(obj)
	# emit the signal 3 times to illustrate how the index works in
	# assert_signal_emitted_with_parameters
	obj.emit_signal('some_signal', 1, 2, 3)
	obj.emit_signal('some_signal', 'a', 'b', 'c')
	obj.emit_signal('some_signal', 'one', 'two', 'three')

	gut.p('-- passing --')
	# Passes b/c the default parameters to check are the last emission of
	# the signal
	assert_signal_emitted_with_parameters(obj, 'some_signal', ['one', 'two', 'three'])
	# Passes because the parameters match the specified emission based on index.
	assert_signal_emitted_with_parameters(obj, 'some_signal', [1, 2, 3], 0)

	gut.p('-- failing --')
	# Fails with specific message that the object does not have the signal
	assert_signal_emitted_with_parameters(obj, 'signal_does_not_exist', [])
	# Fails because the object passed is not being watched
	assert_signal_emitted_with_parameters(SignalObject.new(), 'some_signal', [])
	# Fails because parameters do not match latest emission
	assert_signal_emitted_with_parameters(obj, 'some_signal', [1, 2, 3])
	# Fails because the parameters for the specified index do not match
	assert_signal_emitted_with_parameters(obj, 'some_signal', [1, 2, 3], 1)
```
#### <a name="assert_signal_emit_count"> assert_signal_emit_count(object, signal_name)
Asserts that a signal fired a specific number of times.

``` python
class SignalObject:
	func _init():
		add_user_signal('some_signal')
		add_user_signal('other_signal')

func test_assert_signal_emit_count():
	var obj_a = SignalObject.new()
	var obj_b = SignalObject.new()

	watch_signals(obj_a)
	watch_signals(obj_b)
	obj_a.emit_signal('some_signal')
	obj_a.emit_signal('some_signal')

	obj_b.emit_signal('some_signal')
	obj_b.emit_signal('other_signal')

	gut.p('-- passing --')
	assert_signal_emit_count(obj_a, 'some_signal', 2)
	assert_signal_emit_count(obj_a, 'other_signal', 0)

	assert_signal_emit_count(obj_b, 'other_signal', 1)

	gut.p('-- failing --')
	# Fails with specific message that the object does not have the signal
	assert_signal_emit_count(obj_a, 'signal_does_not_exist', 99)
	# Fails because the object passed is not being watched
	assert_signal_emit_count(SignalObject.new(), 'some_signal', 99)
	# The following fail for obvious reasons
	assert_signal_emit_count(obj_a, 'some_signal', 0)
	assert_signal_emit_count(obj_b, 'other_signal', 283)
```
#### <a name="get_signal_emit_count"> get_signal_emit_count(object, signal_name)
This will return the number of times a signal was fired.  This gives you the freedom to make more complicated assertions if the spirit moves you.  This will return -1 if the signal was not fired or the object was not being watched, or if the object does not have the signal.

#### <a name="get_signal_parameters"> get_signal_parameters(object, signal_name, index=-1)
If you need to inspect the parameters in order to make more complicate assertions, then this will give you access to the parameters of any watched signal.  This works the same way that `assert_signal_emitted_with_parameters` does.  It takes an object, signal name, and an optional index.  If the index is not specified then the parameters from the most recent emission will be returned.  If the object is not being watched, the signal was not fired, or the object does not have the signal then `null` will be returned.
``` python
class SignalObject:
	func _init():
		add_user_signal('some_signal')
		add_user_signal('other_signal')

func test_get_signal_parameters():
	var obj = SignalObject.new()
	watch_signals(obj)
	obj.emit_signal('some_signal', 1, 2, 3)
	obj.emit_signal('some_signal', 'a', 'b', 'c')

	gut.p('-- passing --')
	# passes because get_signal_parameters returns the most recent emission
	# by default
	assert_eq(get_signal_parameters(obj, 'some_signal'), ['a', 'b', 'c'])
	assert_eq(get_signal_parameters(obj, 'some_signal', 0), [1, 2, 3])
	# if the signal was not fired null is returned
	assert_eq(get_signal_parameters(obj, 'other_signal'), null)
	# if the signal does not exist or isn't being watched null is returned
	assert_eq(get_signal_parameters(obj, 'signal_dne'), null)

	gut.p('-- failing --')
	assert_eq(get_signal_parameters(obj, 'some_signal'), [1, 2, 3])
	assert_eq(get_signal_parameters(obj, 'some_signal', 0), ['a', 'b', 'c'])
```
#### <a name="assert_file_exists"> assert_file_exists(file_path)
asserts a file exists at the specified path
``` python
func setup():
	gut.file_touch('user://some_test_file')

func teardown():
	gut.file_delete('user://some_test_file')

func test_assert_file_exists():
	gut.p('-- passing --')
	assert_file_exists('res://addons/gut/gut.gd') # PASS
	assert_file_exists('user://some_test_file') # PASS

	gut.p('-- failing --')
	assert_file_exists('user://file_does_not.exist') # FAIL
	assert_file_exists('res://some_dir/another_dir/file_does_not.exist') # FAIL  
```
#### <a name="assert_file_does_not_exist"> assert_file_does_not_exist(file_path)
asserts a file does not exist at the specified path
``` python
func setup():
	gut.file_touch('user://some_test_file')

func teardown():
	gut.file_delete('user://some_test_file')

func test_assert_file_does_not_exist():
	gut.p('-- passing --')
	assert_file_does_not_exist('user://file_does_not.exist') # PASS
	assert_file_does_not_exist('res://some_dir/another_dir/file_does_not.exist') # PASS

	gut.p('-- failing --')
	assert_file_does_not_exist('res://addons/gut/gut.gd') # FAIL
```
#### <a name="assert_file_empty"> assert_file_empty(file_path)
asserts the specified file is empty
``` python
func setup():
	gut.file_touch('user://some_test_file')

func teardown():
	gut.file_delete('user://some_test_file')

func test_assert_file_empty():
	gut.p('-- passing --')
	assert_file_empty('user://some_test_file') # PASS

	gut.p('-- failing --')
	assert_file_empty('res://addons/gut/gut.gd') # FAIL
```
#### <a name="assert_file_not_empty"> assert_file_not_empty(file_path)
asserts the specified file is not empty
``` python
func setup():
	gut.file_touch('user://some_test_file')

func teardown():
	gut.file_delete('user://some_test_file')

func test_assert_file_not_empty():
	gut.p('-- passing --')
	assert_file_not_empty('res://addons/gut/gut.gd') # PASS

	gut.p('-- failing --')
	assert_file_not_empty('user://some_test_file') # FAIL
```
#### <a name="assert_extends"> assert_extends(object, a_class, text)
Asserts that "object" extends "a_class".  object must be an instance of an object.  It cannot be any of the built in classes like Array or Int or Float.  a_class must be a class, it can be loaded via load, a GDNative class such as Node or Label or anything else.

``` python
func test_assert_extends():
	gut.p('-- passing --')
	assert_extends(Node2D.new(), Node2D)
	assert_extends(Label.new(), CanvasItem)
	assert_extends(SubClass.new(), BaseClass)
	# Since this is a test script that inherits from test.gd, so
	# this passes.  It's not obvious w/o seeing the whole script
	# so I'm telling you.  You'll just have to trust me.
	assert_extends(self, load('res://addons/gut/test.gd'))

	var Gut = load('res://addons/gut/gut.gd')
	var a_gut = Gut.new()
	assert_extends(a_gut, Gut)

	gut.p('-- failing --')
	assert_extends(Node2D.new(), Node2D.new())
	assert_extends(BaseClass.new(), SubClass)
	assert_extends('a', 'b')
	assert_extends([], Node)
```
#### <a name="assert_get_set_methods"> assert_get_set_methods(obj, property, default, set_to)
I found that making tests for most getters and setters was repetitious and annoying.  Enter `assert_get_set_methods`.  This assertion handles 80% of your getter and setter testing needs.  Given an object and a property name it will verify:
 * The object has a method called `get_<PROPERTY_NAME>`
 * The object has a method called `set_<PROPERTY_NAME>`
 * The method `get_<PROPERTY_NAME>` returns the expected default value when first called.
 * Once you set the property, the `get_<PROPERTY_NAME>`will return the value passed in.

On the inside Gut actually performs up to 4 assertions.  So if everything goes right you will have four passing asserts each time you call `assert_get_set_methods`.  I say "up to 4 assertions" because there are 2 assertions to make sure the object has the methods and then 2 to verify they act correctly.  If the object does not have the methods, it does not bother running the tests for the methods.
``` python
class SomeClass:
	var _count = 0

	func get_count():
		return _count
	func set_count(number):
		_count = number

	func get_nothing():
		pass
	func set_nothing(val):
		pass

func test_assert_get_set_methods():
  var some_class = SomeClass.new()
  gut.p('-- passing --')
  assert_get_set_methods(some_class, 'count', 0, 20) # 4 PASSING

  gut.p('-- failing --')
  # 1 FAILING, 3 PASSING
  assert_get_set_methods(some_class, 'count', 'not_default', 20)  
  # 2 FAILING, 2 PASSING
  assert_get_set_methods(some_class, 'nothing', 'hello', 22)
  # 2 FAILING
  assert_get_set_methods(some_class, 'does_not_exist', 'does_not', 'matter')
```
#### gut.p(text, level=0, indent=0)
Print info to the GUI and console (if enabled).  You can see examples if this in the sample code above.  In order to be able to spot check the sample code, I print out a divider between the passing and failing tests.

#### gut.pause_before_teardown()
This method will cause Gut to pause before it moves on to the next test.  This is useful for debugging, for instance if you want to investigate the screen or anything else after a test has finished executing.  See also `set_ignore_pause_before_teardown`

#### yield_for(time_in_seconds)
This simplifies the code needed to pause the test execution for a number of seconds so the thing that you are testing can run its course in real time.  There are more details in the Yielding section.  It is designed to be used with the `yield` built in.  The following example will pause your test execution (and only the test execution) for 2 seconds before continuing.  You must call an assert or `pending` or `end_test()` after a yield or the test will never stop running.
``` python
class MovingNode:
	extends Node2D
	var _speed = 2

	func _ready():
		set_process(true)

	func _process(delta):
		set_pos(get_pos() + Vector2(_speed * delta, 0))

func test_illustrate_yield():
	var moving_node = MovingNode.new()
	add_child(moving_node)
	moving_node.set_pos(Vector2(0, 0))

	# While the yield happens, the node should move
	yield(yield_for(2), YIELD)
	assert_gt(moving_node.get_pos().x, 0)
	assert_between(moving_node.get_pos().x, 3.9, 4, 'it should move almost 4 whatevers at speed 2')
```

#### yield_to(object, signal_name, max_time)
`yield_to` allows you to yield to a signal just like `yield` but for a maximum amount of time.  This keeps tests moving along when signals are not emitted.  Just like with any test that has a yield in it, you must call an assert or `pending` or `end_test()` after a yield or the test will never stop running.

As a bonus, `yield_to` does an implicit call to `watch_signals` so you can easily make signal based assertions afterwards.
``` python
class TimedSignaler:
	extends Node2D
	var _time = 0

	signal the_signal
	func _init(time):
		_time = time

	func start():
		var t = Timer.new()
		add_child(t)
		t.set_wait_time(_time)
		t.connect('timeout', self, '_on_timer_timeout')
		t.set_one_shot(true)
		t.start()

	func _on_timer_timeout():
		emit_signal('the_signal')

func test_illustrate_yield_to_with_less_time():
	var t = TimedSignaler.new(5)
	add_child(t)
	t.start()
	yield(yield_to(t, 'the_signal', 1), YIELD)
	# since we setup t to emit after 5 seconds, this will fail because we
	# only yielded for 1 second vai yield_to
	assert_signal_emitted(t, 'the_signal', 'This will fail')

func test_illustrate_yield_to_with_more_time():
	var t = TimedSignaler.new(1)
	add_child(t)
	t.start()
	yield(yield_to(t, 'the_signal', 5), YIELD)
	# since we wait longer than it will take to emit the signal, this assert
	# will pass
	assert_signal_emitted(t, 'the_signal', 'This will pass')
```
#### end_test()
This is a holdover from previous versions.  You should probably use an assert or `pending` to close out a yielded test but you can use this instead if you really really want to.
```
func test_illustrate_end_test():
	yield(yield_for(1), YIELD)
	# we don't have anything to test yet, or at all.  So we
	# call end_test so that Gut knows all the yielding has
	# finished.
	end_test()
```
## <a name="gut_methods"> Methods for Configuring the Execution of Tests
These methods would be used inside the scene you created at `res://test/tests.tcn`.  These methods can be called against the Gut node you created.  Most of these are not necessary anymore since you can configure Gut in the editor but they are here if you want to use them.  Simply put `get_node('Gut').` in front of any of them.  

<i>__**__ indicates the option can be set via the editor</i>
* `add_script(script, select_this_one=false)` add a script to be tetsted with test_scripts
* __**__`add_directory(path, prefix='test_', suffix='.gd')` add a directory of test scripts that start with prefix and end with suffix.  Subdirectories not included.  This method is useful if you have more than the 6 directories the editor allows you to configure.  You can use this to add others.
* __**__`test_scripts()` run all scripts added with add_script or add_directory.  If you leave this out of your script then you can select which script will run, but you must press the "run" button to start the tests.
* `test_script(script)` runs a single script immediately.
* __**__`select_script(script_name)` sets a script added with `add_script` or `add_directory` to be initially selected.  This allows you to run one script instead of all the scripts.  This will select the first script it finds that contains the specified string.
* `get_test_count()` return the number of tests run
* `get_assert_count()` return the number of assertions that were made
* `get_pass_count()` return the number of tests that passed
* `get_fail_count()` return the number of tests that failed
* `get_pending_count()` return the number of tests that were pending
* __**__`get/set_should_print_to_console(should)` accessors for printing to console
* `get_result_text()` returns all the text contained in the GUI
* `clear_text()` clears the text in the GUI
* `set_ignore_pause_before_teardown(should_ignore)` causes GUI to disregard any calls to pause_before_teardown.  This is useful when you want to run in a batch mode.
* __**__`set_yield_between_tests(should)` will pause briefly between every 5 tests so that you can see progress in the GUI.  If this is left out, it  can seem like the program has hung when running longer test sets.
* __**__`get/set_log_level(level)` see section on log level for list of values.
* __**__`disable_strict_datatype_checks(true)` disables strict datatype checks.  See section on "Strict type checking" before disabling.

# <a name="extras"> Extras

##  <a name="strict"> Strict type checking
Gut performs type checks in the asserts when comparing two different types that would normally cause a runtime error.  With the type checking enabled (on be default) your test will fail instead of crashing.  Some types are ok to be compared such as Floats and Integers but if you attempt to compare a String with a Float your test will fail instead of blowing up.

You can disable this behavior if you like by calling `disable_strict_datatype_checks(true)` on your Gut node or by clicking the checkbox to "Disable Strict Datatype Checks" in the editor.

##  <a name="files"> File Manipulation Methods for Tests
Use these methods in a test or setup/teardown method to make file related testing easier.  These all exist on the Gut object so they must be prefixed with `gut`
* `gut.file_touch(path)` create an empty file if it doesn't exist.
* `gut.file_delete(path)` delete a file
* `gut.is_file_empty(path)` checks if a file is empty
* `gut.directory_delete_files` deletes all files in a directory.  does not delete subdirectories or any files in them.

##  <a name="watch"> Watching tests as they execute
When running longer tests it can appear as though the program or Gut has hung.  To address this and see the tests as they execute, a short yield was added between tests.  To enable this feature call `set_yield_between_tests(true)` before running your tests or use the "Yield Between Tests" in the Editor.

##  <a name="output_detail"> Output Detail
The level of detail that is printed to the screen can be changed using the slider on the dialog or by calling `set_log_level` with one of the following constants defined in Gut

* LOG_LEVEL_FAIL_ONLY (0)
* LOG_LEVEL_TEST_AND_FAILURES (1)
* LOG_LEVEL_ALL_ASSERTS (2)

##  <a name="printing"> Printing info
The `gut.p` method allows you to print information out indented under the test output.  It has an optional 2nd parameter that sets which log level to display it at.  Use one of the constants in the section above to set it.  The default is `LOG_LEVEL_FAIL_ONLY` which means the output will always be visible.  


#  <a name="advanced"> Advanced Testing

## <a name="simulate"> Simulate
The simulate method will call the `_process` or `_fixed_process` on a tree of objects.  It takes in the base object, the number of times to call the methods and the delta value to be passed to `_process` or `_fixed_process` (if the object has one).  This will only cause code directly related to the `_process` and `_fixed_process` methods to run.  Signals will be sent, methods will be called but timers, for example, will not fire since the main loop of the game is not actually running.  Creating a test that yields is a better solution for testing such things.

Example
``` python

# --------------------------------
# res://scripts/my_object.gd
# --------------------------------
extends Node2D
  var a_number = 1

  func _ready():
    set_process(true)

  func _process(delta):
    a_number += 1

# --------------------------------
# res://scripts/another_object.gd
# --------------------------------
extends Node2D
  var another_number = 1

  func _ready():
    set_fixed_process(true)

  func _fixed_process(delta):
    another_number += 1

# --------------------------------
# res://test/unit/test_my_object.gd
# --------------------------------

# ...

var MyObject = load('res://scripts/my_object.gd')
var AnotherObject = load('res://scripts/another_object')

# ...

# Given that SomeCoolObj has a _process method that incrments a_number by 1
# each time _process is called, and that the number starts at 0, this test
# should pass
func test_does_something_each_loop():
  var my_obj = MyObject.new()
  add_child(my_obj)
  gut.simulate(my_obj, 20, .1)
  assert_eq(my_obj.a_number, 20, 'Since a_number is incremented in _process, it should be 20 now')

# Let us also assume that AnotherObj acts exactly the same way as
# but has SomeCoolObj but has a _fixed_process method instead of
# _process.  In that case, this test will pass too since all child objects
# have the _process or _fixed_process method called.
func test_does_something_each_loop():
  var my_obj = MyObject.new()
  var other_obj = AnotherObj.new()

  add_child(my_obj)
  my_obj.add_child(other_obj)

  gut.simulate(my_obj, 20, .1)

  assert_eq(my_obj.a_number, 20, 'Since a_number is incremented in _process, \
                                  it should be 20 now')
  assert_eq(other_obj.another_number, 20, 'Since other_obj is a child of my_obj \
                                           and another_number is incremened in \
                                           _fixed_process then it should be 20 now')

```
##  <a name="yielding"> Yielding during a test

I'm not going to try and explain yielding here.  It can be a bit confusing and [Godot does a pretty good job of it already](http://docs.godotengine.org/en/latest/reference/gdscript.html#coroutines).  Gut has support for yielding though, so you can yield at anytime in your test.  The one caveat is that you must use one of the various asserts or `pending()` after the yield.  Otherwise Gut won't know that the yield has finished.  You can optionally use `end_test()` if an assert or `pending` doesn't make sense for some reason.

When might you want to yield?  Yielding is very handy when you want to wait for a signal to occur instead of running for a finite amount of time.  For example, you could have your test yield until your character gets hit by something (`yield(my_char, 'hit')`).  An added bonus of this approach is that you can watch everything happen.  In your test you create your character, the object to hit it, and then watch the interaction play out.

Here's an example of yielding to a custom signal.
``` python
func test_yield_to_custom_signal():
	my_object = ObjectToTest.new()
	add_child(my_object)
	yield(my_object, 'custom_signal')
	assert_true(some_condition, 'After signal fired, this should be true')
```
### yield_to
Sometimes you need to wait for a signal to be emitted, but you can never really be sure it will, we are making tests after all.  You could `yield` to that signal in your test and hope it gets emitted.  If it doesn't though, your test will just hang forever.  The `yield_to` method addresses this by allowing you to `yield` to a signal or a maximum amount of time, whichever occurs first.  You must make sure the 2nd parameter to `yield` is the `YIELD` constant.  This constant is available to all test scripts.  As an extra bonus, Gut will watch the signals on the object you passed in, so you can save yourself a call to `watch_signals` if you want, but you don't have to.  How all this magic works is covered a couple of sections down.

``` python
# wait for my_object to emit the signal 'my_signal'
# or 5 seconds, whichever comes first.
yield(yield_to(my_object, 'my_signal', 5), YIELD)  
assert_signal_emitted(my_object, 'my_signal', \
                     'Maybe it did, maybe it didnt, but we still got here.')
```

### yield_for
Another use case I have come across is when creating integration tests and you want to verify that a complex interaction ends with an expected result.  In this case you might have an idea of how long the interaction will take to play out but you don't have a signal that you can attach to.  Instead you want to pause your test execution until that time has elapsed.  For this, Gut has the `yield_for` method.  For example `yield(yield_for(5), YIELD)` will pause your test execution for 5 seconds while the rest of your code executes as expected.  You must make sure the 2nd parameter to `yield` is the `YIELD` constant.  This constant is available to all test scripts.  How all this magic works is covered a couple of sections down.

Here's an example of yielding for 5 seconds.
``` python
func test_wait_for_a_bit():
	my_object = ObjectToTest.new()
	my_object.do_something()
	#wait 5 seconds
	yield(yield_for(5), YIELD)
	gut.assert_eq(my_object.some_property, 'some value', 'After waiting 5 seconds, this property should be set')
```

### pause_before_teardown
Sometimes it's also helpful to just watch things play out.  Yield is great for that, you just create a couple objects, set them to interact and then yield.  You can leave the yields in or take them out if your test passes without them.  You can also use the `pause_before_teardown` method that will pause test execution before it runs `teardown` and moves onto the next test.  This keeps the game loop running after the test has finished and you can see what everything looks like.

### How Yielding and Gut Works
For those that are interested, Gut is able to detect when a test has called yield because the method returns a special class back.  Gut itself will then `yield` to an internal timer and check to see if an assertion or `pending()` or `end_test()` has been called every second, if not it waits again.

If you only yielded using `yield_for` then Gut would always know when to resume the test and could handle it itself.  You can yield to anything though and Gut cannot tell the difference.  Also, when you yield to something else Gut has no way of knowing when the method has continued so you have to tell it when you are done so it will stop waiting.  One side effect of this is that if you `yield` multiple times in the same test, Gut can't tell.  It continues to wait from the first yield and you won't see any additional "yield detected" outputs in the GUI or console.

The `yield_for()` method and `YIELD` constant are some syntax sugar built into the `Test` object.  `yield` takes in an object and a signal.  The `yield_for` method kicks off a timer inside Gut that will run for however many seconds you passed in.  It also returns the Gut object so that `yield` has an object to yield to.  The `YIELD` constant contains the name of the signal that Gut emits when the timer finishes.

`yield_to` works similarly to `yield_for` except it takes the extra step that Gut will watch the signal you pass in.  It will emit the same signal (`YIELD`) when it detects the signal you specified or it will emit the signal when the timer times out.

#  <a name="command_line"> Running Gut from the Command Line
Also supplied in this repo is the gut_cmdln.gd script that can be run from the command line so that you don't have to create a scene to run your tests.  One of the main reasons to use this approach instead of going through the editor is that you get to see error messages generated by Godot in the context of your running tests.  You also see any `print` statements you put in  your code in the context of all the Gut generated output.  It's a bit quicker to get started and is a bit cooler if I do say so.  The biggest downside is that debugging your code/tests is a little more difficult since you won't be able to interact with the editor when something blows up.

From the command line, at the root of your project, use the following command to run the script.  Use the options below to run tests.
	`godot -d -s addons/gut/gut_cmdln.gd`

The -d option tells Godot to run in debug mode which is helpful.  The -s option tells Godot to run a script.

### Options
_Output from the command line help (-gh)_
```
---------------------------------------------------------                               
This is the command line interface for the unit testing tool Gut.  With this
interface you can run one or more test scripts from the command line.  In order
for the Gut options to not clash with any other Godot options, each option
starts with a "g".  Also, any option that requires a value will take the form of
"-g<name>=<value>".  There cannot be any spaces between the option, the "=", or
inside a specified value or Godot will think you are trying to run a scene.       

Options                                                                                                               
-------                                                                                                               
  -gtest          Comma delimited list of tests to run
  -gdir           Comma delimited list of directories to add tests from.
  -gprefix        Prefix used to find tests when specifying -gdir.  Default
                  "test_"
  -gsuffix        Suffix used to find tests when specifying -gdir.  Default
                  ".gd"
  -gexit          Exit after running tests.  If not specified you have to
                  manually close the window.
  -glog           Log level.  Default 1
  -gignore_pause  Ignores any calls to gut.pause_before_teardown.
  -gselect        Select a script to run initially.  The first script that was
                  loaded using -gtest or -gdir that contains the specified
                  string will be executed.  You may run others by interacting
                  with the GUI.
  -gutloc         Full path (including name) of the gut script.  Default
                  res://addons/gut/gut.gd
  -gh             Print this help
---------------------------------------------------------   
```

### Examples

Run godot in debug mode (-d), run a test script (-gtest), set log level to lowest (-glog), exit when done (-gexit)

`godot -s addons/gut/gut_cmdln.gd -d -gtest=res://test/unit/sample_tests.gd -glog=1 -gexit`

Load all test scripts that begin with 'me_' and end in '.res' and run me_only_only_me.res (given that the directory contains the following scripts:  me_and_only_me.res, me_only.res, me_one.res, me_two.res).  I don't specify the -gexit on this one since I might want to run all the scripts using the GUI after I run this one script.

`godot -s addons/gut/gut_cmdln.gd -d -gdir=res://test/unit -gprefix=me_ -gsuffix=.res -gselect=only_me`

### Alias
Make your life easier by creating an alias that includes your most frequent options.  Here's the one I use in bash:

`alias gut='godot -d -s addons/gut/gut_cmdln.gd -gdir=res://test/unit,res://test/integration -gexit -gignore_pause'`

This alias loads up all the scripts I want from my testing directories and sets some other flags.  With this, if I want to run 'test_one.gd', I just enter `gut -gselect=test_one.gd`.

### Common Errors
I really only know of one so far, but if you get a space in your command somewhere, you might see something like this:
```
ERROR:  No loader found for resource: res://samples3
At:  core\io\resource_loader.cpp:209
ERROR:  Failed loading scene: res://samples3
At:  main\main.cpp:1260
```
I got this one when I accidentally put a space instead of an "=" after -gselect.


#  <a name="contributing"> Contributing
This testing tool has tests of course.  All Gut related tests are found in the `test/unit` and `test/integration` directories.  Any enhancements or bug fixes should have a corresponding pull request with new tests.

The bulk of the tests for Gut are in [test_gut.gd](gut_tests_and_examples/test/unit/test_gut.gd) and [test_test.gd](gut_tests_and_examples/test/unit/test_test.gd).  [test_signal_watcher.gd](gut_tests_and_examples/test/unit/test_signal_watcher.gd) tests the class used to track the emitting of signals.  The other test scripts in `unit` and `integration` should be run and their output spot checked since they test other parts of Gut that aren't easily testabled.

For convenience, the `main.tscn` includes a handy "Run Gut Unit Tests" button that will kick off all the essential test scripts.

# Who do I talk to?
You can talk to me, Butch Wesley

* Github:  bitwes
* Godot forums:  bitwes
