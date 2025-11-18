# Doubling-Singletons
You can create pseudo-doubles of Engine Singletons (not to be confused with Autoloads) using `double_singleton` or `partial_double_singleton`.  Godot Engine Singletons are single instance classes that are created by Godot.  `Input`, `OS`, and `Time` are Engine Singletons that are commonly used.  A full list of supported Engine Singletons can be found below.

All Engine Singletons extend `Object` but their doubles extend `RefCounted`.  This was done so that they would be freed automatically.

__These doubles do not replace the existing Engine Singleton__, so they must be injected into a variable in your script.  You must then use this local singleton reference in your script instead of directly referencing the Singleton.  If you use `:=` you still get all autocomplete features in the editor.

```gdscript
class_name Player

var my_local_input_singleton_ref := Input

func _physics_process(delta):
    if(my_local_input_singleton_ref.is_action_just_pressed("jump")):
....
```

```gdscript
extends GutTest

func test_player_does_something_with_input():
    var dbl_input = partial_double_singleton(Input).new()
    var p = Player.new()
    p.my_local_input_singleton_ref = dbl_input

    stub(dbl_input.is_action_just_pressed)\
        .to_return(true)\
        .when_passed("jump")
    ...
```
# Differences to a normal Double
Engine Singleton doubles are different from normal doubles in the following way:
* Singleton doubles wrap around a an Engine Singleton, they do not extend it.
* Properties are copied from the source Singleton when an instance of the double is created.  This means the intial values will change (on calls to `.new()`) if the Singleton's properties change.
* `double_singleton` and `partial_double_singleton` parameters are checked against a list of known-valid Engine Singletons.
* Inherit from `RefCounted`, not the source Engine Singleton or `Object`.
* Parial doubles of singletons, or stubbing `to_call_super`, calls methods on the source Engine Singleton.
* The properties/methods of `Object` are never included in the double, regardless of the Double Strategy.
* Ignoring a method on an Engine Singleton means it will not exist in the double, whereas normal doubles just don't get overrides for the ignored method.
```gdscript
ignore_method_when_doubling(Time, 'get_ticks_msec')
var inst = double_singleton(Time).new()
assert_false(inst.has_method('get_ticks_msec'))
```


# Example

This example has a class that uses the `Time` singleton.  We make a double of `Time` in the tests and "inject" it into the instance of `UsesTime` we are testing.  We then stub the double to return values that allow us to verify `UsesTime` is correctly using `Time`.
``` gdscript
class_name UsesTime

# Must have a reference to Engine Singleton that we can
# inject our double into.
var t := Time

var _start_time = -1
func start():
    _start_time = t.get_ticks_msec()

func end():
    var monday_extra = 0
    if(t.get_date_dict_from_system().weekday == t.WEEKDAY_MONDAY):
        monday_extra = 10
    return t.get_ticks_msec() - _start_time + monday_extra
```

``` gdscript
extends GutTest

# Fun fact, this test will fail if ran on any Monday.  I wrote this on a
# Wednesday, so it passes.  This is a doozy of a flakey test.  Don't make
# tests
func test_calling_end_returns_elapsed_time_using_msecs():
	var dbl_time = partial_double_singleton(Time).new()
	var inst = UsesTime.new()
	inst.t = dbl_time

	stub(dbl_time.get_ticks_msec).to_return(0)
	inst.start()
	stub(dbl_time.get_ticks_msec).to_return(10)
	assert_eq(inst.end(), 10)


# Illustrate that enums are included in singleton doubles.
func test_on_mondays_elapsed_time_is_longer_because_time_moves_slower_on_mondays():
	var dbl_time = double_singleton(Time).new()
	var inst = UsesTime.new()

	inst.t = dbl_time
	stub(dbl_time.get_date_dict_from_system)\
		.to_return({
			"year": 2025,
			"month": 1,
			"day": 1,
			"weekday": Time.WEEKDAY_MONDAY})

	stub(dbl_time.get_ticks_msec).to_return(0)
	inst.start()
	stub(dbl_time.get_ticks_msec).to_return(10)
	assert_eq(inst.end(), 20)
```

# Eligible Singletons
I have verified that a double of these can be created and instantiated.  All the ways they could be used has not been explored.  Your mileage may vary.  Please open an issue if you encounter a problem when doubling any of these Engine Singletons.

* [AudioServer](https://docs.godotengine.org/en/stable/classes/class_audioserver.html)
* [CameraServer](https://docs.godotengine.org/en/stable/classes/class_cameraserver.html)
* [ClassDB](https://docs.godotengine.org/en/stable/classes/class_classdb.html)
* [DisplayServer](https://docs.godotengine.org/en/stable/classes/class_displayserver.html)
* [Engine](https://docs.godotengine.org/en/stable/classes/class_engine.html)
* [EngineDebugger](https://docs.godotengine.org/en/stable/classes/class_enginedebugger.html)
* [GDExtensionManager](https://docs.godotengine.org/en/stable/classes/class_gdextensionmanager.html)
* [Geometry2D](https://docs.godotengine.org/en/stable/classes/class_geometry2d.html)
* [Geometry3D](https://docs.godotengine.org/en/stable/classes/class_geometry3d.html)
* [GodotNavigationServer2D](https://docs.godotengine.org/en/stable/classes/class_godotnavigationserver2d.html)
* [IP](https://docs.godotengine.org/en/stable/classes/class_ip.html)
* [Input](https://docs.godotengine.org/en/stable/classes/class_input.html)
* [InputMap](https://docs.godotengine.org/en/stable/classes/class_inputmap.html)
* [JavaClassWrapper](https://docs.godotengine.org/en/stable/classes/class_javaclasswrapper.html)
* [JavaScriptBridge](https://docs.godotengine.org/en/stable/classes/class_javascriptbridge.html)
* [Marshalls](https://docs.godotengine.org/en/stable/classes/class_marshalls.html)
* [NativeMenuMacOS](https://docs.godotengine.org/en/stable/classes/class_nativemenumacos.html)
* [NavigationMeshGenerator](https://docs.godotengine.org/en/stable/classes/class_navigationmeshgenerator.html)
* [NavigationServer3D](https://docs.godotengine.org/en/stable/classes/class_navigationserver3d.html)
* [OS](https://docs.godotengine.org/en/stable/classes/class_os.html)
* [Performance](https://docs.godotengine.org/en/stable/classes/class_performance.html)
* [PhysicsServer2D](https://docs.godotengine.org/en/stable/classes/class_physicsserver2d.html)
* [PhysicsServer2DManager](https://docs.godotengine.org/en/stable/classes/class_physicsserver2dmanager.html)
* [PhysicsServer3D](https://docs.godotengine.org/en/stable/classes/class_physicsserver3d.html)
* [PhysicsServer3DManager](https://docs.godotengine.org/en/stable/classes/class_physicsserver3dmanager.html)
* [ProjectSettings](https://docs.godotengine.org/en/stable/classes/class_projectsettings.html)
* [RenderingServer](https://docs.godotengine.org/en/stable/classes/class_renderingserver.html)
* [ResourceLoader](https://docs.godotengine.org/en/stable/classes/class_resourceloader.html)
* [ResourceSaver](https://docs.godotengine.org/en/stable/classes/class_resourcesaver.html)
* [ResourceUID](https://docs.godotengine.org/en/stable/classes/class_resourceuid.html)
* [TextServerManager](https://docs.godotengine.org/en/stable/classes/class_textservermanager.html)
* [ThemeDB](https://docs.godotengine.org/en/stable/classes/class_themedb.html)
* [Time](https://docs.godotengine.org/en/stable/classes/class_time.html)
* [TranslationServer](https://docs.godotengine.org/en/stable/classes/class_translationserver.html)
* [WorkerThreadPool](https://docs.godotengine.org/en/stable/classes/class_workerthreadpool.html)
* [XRServer](https://docs.godotengine.org/en/stable/classes/class_xrserver.html)