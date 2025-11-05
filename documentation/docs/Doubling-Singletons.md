GUT provides a mechanism for creating pseudo-doubles of Engine Singletons (not to be confused with Autoloads).  Godot Engine Singletons are single instance classes that are created by Godot.  `Input`, `OS`, and `Time` are Engine Singletons that are commonly used.  A full list of supported Engine Singletons can be found below.

In many cases (probably all) you cannot inherit from the classes of Engine Singletons.  To get around this, Gut provides the `double_singleton` and `partial_double_singleton` methods.  These methods create doubles that are slightly different than a normal double.  These doubles contain all the methods, properties and constants of their source class but do not inherit from them.  This means that there is no super class to pull functionality from.  They are more like a wrapper around the source Engine Singleton.  Anytime a method in a singleton double is configured to call super (`stub(...).to_call_super()` or a `partial_double_singleton`) the method will call the corresponding method on the source Engine Singleton, and not functionality in the parent class.

All Engine Singletons extend `Object` but their doubles extend `RefCounted`.  This was done so that they would be freed automatically.  This should not have any impact on their intended use, but could have unforseen consequences.  I can't imagine what they could be, but that's how unforseen works.  Open an issue if anything weird happens.

Engine Singleton doubles are different from normal doubles in the following way:
* Creation methods require the name of an Engine Singleton instead of a path or loaded classes.
* Singleton doubles wrap around a an Engine Singleton, not extend it.
* Inherit from `Object`, not the source Engine Singleton.
* Stubbing `to_call_super` calls methods on the source Engine Singleton.
* Ignoring a method on an Engine Singleton means it will not exist in the double.
```gdscript
ignore_method_when_doubling(Time, 'get_ticks_msec')
var inst = double_singleton(Time).new()
assert_false(inst.has_method('get_ticks_msec'))
```


# `double_singleton` Example
#### player.gd
``` gdscript

# create a local reference to Input that can be overwritten by test code.
var _input = Input
var _is_jumping = false

# Make sure to only reference _input in this method.
func _process(delta):
    if(_input.is_action_just_pressed("jump")):
        do_jump

func jump():
    _is_jumping = true
    ...

func is_jumping():
    return _is_jumping
```

#### test_player.gd
``` gdscript
```


# Eligible Singletons
These Engine Singletons were found to be doublable but have not been tested.

|
[ARVRServer](https://docs.godotengine.org/en/stable/classes/class_arvrserver.html) |
[AudioServer](https://docs.godotengine.org/en/stable/classes/class_audioserver.html) |
[CameraServer](https://docs.godotengine.org/en/stable/classes/class_cameraserver.html) |
[ClassDB](https://docs.godotengine.org/en/stable/classes/class_classdb.html) |
[EditorNavigationMeshGenerator](https://docs.godotengine.org/en/stable/classes/class_editornavigationmeshgenerator.html) |
[Engine](https://docs.godotengine.org/en/stable/classes/class_engine.html) |
[Geometry](https://docs.godotengine.org/en/stable/classes/class_geometry.html) |
[Input](https://docs.godotengine.org/en/stable/classes/class_input.html) |
[InputMap](https://docs.godotengine.org/en/stable/classes/class_inputmap.html) |
[IP](https://docs.godotengine.org/en/stable/classes/class_ip.html) |
[JavaClassWrapper](https://docs.godotengine.org/en/stable/classes/class_javaclasswrapper.html) |
[JavaScript](https://docs.godotengine.org/en/stable/classes/class_javascript.html) |
[JSON](https://docs.godotengine.org/en/stable/classes/class_json.html) |
[Marshall](https://docs.godotengine.org/en/stable/classes/class_marshalls.html) |
[OS](https://docs.godotengine.org/en/stable/classes/class_os.html) |
[Performance](https://docs.godotengine.org/en/stable/classes/class_performance.html) |
[Physics2DServer](https://docs.godotengine.org/en/stable/classes/class_physics2dserver.html) |
[PhysicsServer](https://docs.godotengine.org/en/stable/classes/class_physicsserver.html) |
[ProjectSettings](https://docs.godotengine.org/en/stable/classes/class_projectsettings.html) |
[ResourceLoader](https://docs.godotengine.org/en/stable/classes/class_resourceloader.html) |
[ResourceSaver](https://docs.godotengine.org/en/stable/classes/class_resourcesaver.html) |
[TranslationServer](https://docs.godotengine.org/en/stable/classes/class_translationserver.html) |
[VisualScriptEditor](https://docs.godotengine.org/en/stable/classes/class_visualscripteditor.html) |
[VisualServer](https://docs.godotengine.org/en/stable/classes/class_visualserver.html) |
