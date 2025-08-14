# Memory Management


You may have noticed errors similar to this at the end of your run:
```sh
WARNING: 2 RIDs of type "Canvas" were leaked.
     at: _free_rids (servers/rendering/renderer_canvas_cull.cpp:2678)
WARNING: 98 RIDs of type "CanvasItem" were leaked.
     at: _free_rids (servers/rendering/renderer_canvas_cull.cpp:2678)
ERROR: 1 RID allocations of type 'N16RendererViewport8ViewportE' were leaked at exit.
ERROR: 8 RID allocations of type 'PN13RendererDummy14TextureStorage12DummyTextureE' were leaked at exit.
ERROR: 27 RID allocations of type 'PN18TextServerAdvanced22ShapedTextDataAdvancedE' were leaked at exit.
ERROR: 3 RID allocations of type 'PN18TextServerAdvanced12FontAdvancedE' were leaked at exit.
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
     at: cleanup (core/object/object.cpp:2490)
ERROR: 24 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:789)
```
These indicate that when the tests finished running there were existing objects that had not been freed.  These objects are called orphans.

## Orphans
I should add a blurb about leaked references that GUT cannot detect.
* Node orphans
* Leaked References
* verbose flag

The [Godot docs](https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_basics.html#memory-management) has some good information.

Any object that extends Node (or a subclass of Node) and is not currently in the tree is considered an orphan.  Children of orphaned Nodes are considered orphans as well.
```
var orphan_count = Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)
var all_orphan_instance_ids = Node.get_orphan_node_ids()
```

## Autofree Methods
GUT detects when an orphan is created and will log the orphans it finds in each test and at the end of the run.  `GutTest` provides the following methods to ease freeing Nodes.  Each of these methods return what is passed in, so you can save a line or two of code.

Henceforth these will be referred to as an `autofree` method.
  * `autofree` - calls `free` after test finishes
  * `autoqfree` - calls `queue_free` after test finishes
  * `add_child_autofree` - calls `add_child` right away, and `free` after `after_each`.
  * `add_child_autoqfree` - calls `add_child` right away, and `queue_free` after `after_each`.

More info can be found in "Freeing Test Objects" below.

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

## GUT Orphan List
~~GUT, by default, will print a count of any orphans that are created by a test.  Depending on the log level these counts will appear after each test or may just appear after each script.  GUT counts the orphans before each test and warns when the value changes when a test is done.  These counts are summed up for each script as well and a grand total is printed at the end of the run.  You can disable this feature if you want to.~~



### Freeing Test Objects
Freeing up objects in your tests is tedious.  It adds additional lines of code that don't add anything to the test.  To aid in this GUT provides the `autofree` and `autoqfree` functions.  Anything passed to these methods will be freed up after the test runs.  These methods also `return` whatever is passed into them so you can chain them together to cut down on space.
```
var Foo = load('res://foo.gd')
var node = autofree(Node.new())
var bar_scene = autofree(load('res://bar.tscn').instance())
assert_null(autofree(Foo.new()).get_value(), 'default value is null')
```
After test execution is done and `after_each` has been called, GUT will free any objects sent to `autofree` and `autoqfree` (and the `add_child_*` methods).  If either `autoqfree` method is called during a test GUT will pause briefly to give the `queue_free` time to execute.

These functions can be used in a test or the `before_each` but should NOT be used in `before_all`.  If you create an object in `before_all` you must free it yourself in `after_all`.  Using either flavor of `autofree` in `before_all` will cause the object to be freed after the first test is run.


### Using `add_child` in Tests
When you call `add_child` from within a test the object is added as a child of the test script.  The test script is a child of the GUT.  GUT will output a warning if a test script has children when it finishes running (after `after_all`).

It is best to free any children you add in a test in that same test.  GUT has two helper functions that will add the child and free the child after the test.  These are `add_child_autofree` and `add_child_autoqfree`.  These work the same way as `autofree` and `autoqfree` but take the additional step of calling `add_child`.  These methods also return whatever is passed to them so you can cut down on lines of code.
```
func test_foo():
  var node = add_child_autofree(Node.new())
  var node2 = add_child_autoqfree(Node.new())
```

These functions can be used in a test or the `before_each` but should NOT be used in `before_all`.  If you have an object you want to add as a child in `before_all` you must free it yourself in `after_all`.  Using either flavor of `add_child_autofree` in `before_all` will cause the object to be freed after the first test is run.

### Freeing Globals
You can use a [post-run hook](Hooks) to clean up any global objects you have created.

### Automatically Freed Objects
GUT automatically frees any [Doubles](Doubles) or [Partial Doubles](Partial-Doubles) you create.

Calling `autofree` with one of these objects, or manually freeing them yourself will not have any adverse effects.

All children of tests are also freed after the test runs, though a warning is printed out if a test has any children.


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