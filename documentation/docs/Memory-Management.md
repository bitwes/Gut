# Memory Management


You may have noticed errors similar to this at the end of your run:
```sh
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
     at: cleanup (core/object/object.cpp:2490)
ERROR: 24 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:789)
```

These indicate that there were existing objects that had not been freed when your game/tests finished running.  These objects are called orphans.  GUT will display when orphans are created in a test and a list of orphans (except the children of orphans) at the end of a run.

Example of orphans in a test:
``` gdscript
* test_this_makes_two_orphans
    2 Orphans
        * test_two_one:<Node#59944994582>
        * test_two_two:<Node#59961771799>
* test_with_a_scene_orphan
    104 Orphans
        * main:<Node2D#60045657884>(main.gd) + 27
        * GutRunner:<Node2D#60565751588>(GutRunner.gd) + 75
```
GUT displays the name of the node, the node converted to string, and the script of the node if it has one.  If the node has children then the number of all decendents will be listed as `+ x`.

All of GUT's orphan features are wrappers around `Node.get_orphan_node_ids()`.  This static method on `Node` returns the `instance_id` of each orphaned node.

## Orphans
Any Node (or a subclass of Node) that is not currently in the tree is considered an orphan.  Children of orphaned Nodes are also considered orphans.  Orphans aren't necesasrily bad, but they usually indicate a memory leak.

The [Godot docs](https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_basics.html#memory-management) has some useful reading on memory management.  Godot provides the following two mechanisms to get information about orphans.


## Leaked References
You may also see the following error if you have a refernce counted object that could not be freed.
```sh
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
     at: cleanup (core/object/object.cpp:2490)
```
Many times, reference counted objects cannot be freed due to a cyclical reference.  In the simplest case, a cyclical reference happens when two objects have a reference to each other.  When this happens, the references cannot be cleared and therefore referenced object cannot be freed.  The best way to solve this is by using [Weakref](https://docs.godotengine.org/en/latest/classes/class_weakref.html).

Godot does not yet supply any information about these leaked objects, so GUT cannot display any information about them.  Using the `--verbose` flag is the best way to debug these.


# GUT Memory Management Features
Since GUT cannot know if an orphan was created on purpose or not, it will tell you about all the orphans it finds, as soon as it finds them.  GUT provides some methods to make it easier to free objects you create in your tests so GUT is more likely to report an actual orphan and not some test object.


## Autofree Methods
GUT detects when an orphan is created and will log the orphans it finds in each test and at the end of the run.  `GutTest` provides the following methods to ease freeing Nodes you create in your tests.  Each of these methods return what is passed in, so you can save a line or two of code.

Henceforth these will be referred to as an "Autofree" method.
  * `autofree` - calls `free` after `after_each`.
  * `autoqfree` - calls `queue_free` after `after_each`.
  * `add_child_autofree` - calls `add_child` right away, and `free` after `after_each`.
  * `add_child_autoqfree` - calls `add_child` right away, and `queue_free` after `after_each`.


__Notes__:
* It is ok to use any of the Autofree methods `before_each`.


__Warnings:__
* Objects passed to `autofree` and  `autoqfree` are not in the tree and therefore will still cause `assert_no_orphans` to fail.
* Do not use any of the `autofree` methods in `before_all`.  This will cause the objects to be freed after the first test is run.

### Freeing Globals
You can use a [post-run hook](Hooks) to clean up any global objects you have created.


### Automatically Freed Objects
GUT automatically frees any [Doubles](Doubles) or [Partial Doubles](Partial-Doubles) you create.

Calling `autofree` with one of these objects, or manually freeing them yourself will not have any adverse effects.

All children of tests are also freed after the test runs, though a warning is printed out if a test has any children.


## Quick Example:
This test generates an orphan
```gdscript
func test_something():
  var my_node = Node.new()
  assert_not_null(my_node)
```
Here, we use one of the `autofree` methods to automatically free our new node after the test without adding any additional lines of code.
``` gdscript
func test_something():
  # add_child_autofree will add the result of Node.new() to the tree,
  # mark it to be freed after the test, and return the instance created by
  # Node.new().
  var my_node = add_child_autofree(Node.new())
  assert_not_null(my_node)
```

### Using `add_child` in Tests
When you call `add_child` from within a test the object is added as a child of the test script.  The test script is a child of the GUT.  GUT will output a warning if a test script has children when it finishes running (after `after_all`).  If you need an object to exist for the duration of a script, be sure to free it in `after_all`.  All scripts and children of scripts are freed after they are done.



### Testing for Leaks
GUT provides the `assert_no_orphans` method that will assert that the test has not created any new orphans.  Using this can be a little tricky in complicated test scripts.

`assert_no_orphans` will verify that, at the time of calling, the test has not created an new orphans.

`assert_no_orphans` cannot take into account anything you have called `autofree` on.  For one, it's impossible, and it wouldn't tell you much since freeing that object could cause leaks.

A standard memory leak test will create an object, free it, and then verify that you have not created any new orphans.  Based on some bad practices I've done myself I would advise creating tests with and without using `add_child`.

```gdscript
# res://test/unit/test_foo.gd
extends GutTest
...

class TestLeaks:
    extends GutTest
    var Foo = load('res://foo.gd')

    func test_no_leaks():
        var to_free = Foo.new()
        to_free.free()
        assert_not_new_orphans()

    func test_no_leaks_with_add_child():
        var to_free = Foo.new()
        add_child(to_free)
        to_free.free()
        assert_no_orphans()
```
If you must use `queue_free` instead of `free` in your test then you will have to pause before asserting that no orphans have been created.  You can do this with `await`
``` gdscript
func test_no_orphans_queue_free();
  var node = Node.new()
  node.queue_free()
  assert_no_orphans('this will fail')
  await wait_seconds(.2)
  assert_no_orphans('this one passes')
```