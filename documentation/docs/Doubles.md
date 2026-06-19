# Doubles
If you aren't sure what a Double is, check out [Test Double on Wikipedia](https://en.wikipedia.org/wiki/Test_double).

You create a Double by calling the `double` method in your `GutTest` script.  The `double` method accepts a loaded script or loaded scene and returns a class based on the loaded script or scene passed to it.  The returned class/scene wraps the source and the methods defined will not execute the code defined in them.  These doubles can then be [stubbed](Stubbing) and [spied on](Spies) in tests.  You can also create [Partial Doubles](Partial-Doubles) which retain their functionality by default.

Using your double, you can:
* Stub methods to return different values.
* Stub them to call the super method.
* Assert how many times a method was called.
* Assert a method was called with specific parameters.
* And much much more.  See [Stubbing](Stubbing) and [Spies](Spies) for more information.

<hr>

__Warning:__   Native Godot methods are not included in doubles by default.  Native methods are all the non-overridable methods in objects such as `Node`.  This means `_ready` will exist in the double, but `set_position` will not.  A good rule of thumb is that if you didn't write the function, it probably will not be included in your double.  You can include them by changing the [Double-Strategy](Double-Strategy), but there are some complications and gotchas.

<hr>

## Characteristics of a Double
You can double Scripts, Inner Classes, and Packed Scenes.  Once you have a double, you can then call `new` or `instantiate` on it to create instances of a doubled object.

* The double inherits (`extends`) the source.
* Contains all class level variables defined in the source.
* Contains all signals defined in the source.
* Methods defined in the source (and any user defined super class):
  * Do nothing (unless stubbed).
  * Return a default value based on the declared return type of function.  See the list of values below.
  * __All__ parameters are defaulted to `null`, even if they did not have a default value originally.  You can stub parameter defaults (see [Stubbing](Stubbing)).

### Important Caveats
* Any static methods you add to your scripts must be ignored before doubling using `ignore_method_when_doubling`.  More information about this below.
* If your `_init` method has required parameters you must [stub](Stubbing) default values before trying to `double` the object.  This must be done at the object level, prior to calling `double` or `partial_double`
```gdscript
stub(MyClass, '_init').param_defaults(['param_1_default', 'param_2_default', ...])
var dbl = double(MyClass).new()
```
* Inner Classes of the source are not doubled and will retain their functionality.
* You can double Inner Classes, but it requires an extra step.  See the Inner Class section below.
* All instances of Doubles and Partial Doubles are freed when a test finishes.  This means you do not have to free them manually.
* Do not create double instances in `before_all` or reference them in `after_all`.


## Default return values
Starting in Godot 4.7, methods with a declared return type can no longer return `null`.  To this end, GUT now has default values that will be returned from an unstubbed method in a double.  Stubbing a method `to_do_nothing` on a Parial Double will also result in these defaults being returned.

If a method has no declared return type or a `void` return type, then the doubled version will return `null`.

If a method is stubbed to return an invalid value GUT will generate an error but execution will continue.  This will result in an engine error as well.

Gut Error Example:
```
[GUT ERROR]:  Method [explicit_int_return] was stubbed to return invalid value [adsf].
```
Engine Error Example:
```
SCRIPT ERROR: Trying to return a value of type "String" from a function whose return type is "int".
```
Default Values:
```
TYPE_AABB           : AABB(),
TYPE_ARRAY          : [],
TYPE_BASIS          : Basis.IDENTITY,
TYPE_BOOL           : false,
TYPE_CALLABLE       : Callable(),
TYPE_COLOR          : Color.WHITE,
TYPE_DICTIONARY     : {},
TYPE_FLOAT          : 0.0,
TYPE_INT            : 0,
TYPE_NODE_PATH      : NodePath(),
TYPE_OBJECT         : null,
TYPE_PACKED_BYTE_ARRAY      : PackedByteArray(),
TYPE_PACKED_COLOR_ARRAY     : PackedColorArray(),
TYPE_PACKED_FLOAT32_ARRAY   : PackedFloat32Array(),
TYPE_PACKED_FLOAT64_ARRAY   : PackedFloat64Array(),
TYPE_PACKED_INT32_ARRAY     : PackedInt32Array(),
TYPE_PACKED_INT64_ARRAY     : PackedInt64Array(),
TYPE_PACKED_STRING_ARRAY    : PackedStringArray(),
TYPE_PACKED_VECTOR2_ARRAY   : PackedVector2Array(),
TYPE_PACKED_VECTOR3_ARRAY   : PackedVector3Array(),
TYPE_PACKED_VECTOR4_ARRAY   : PackedVector4Array(),
TYPE_PLANE          : Plane.PLANE_XY,
TYPE_PROJECTION     : Projection.IDENTITY,
TYPE_QUATERNION     : Quaternion.IDENTITY,
TYPE_RECT2          : Rect2(0, 0, 0, 0),
TYPE_RECT2I         : Rect2i(0, 0, 0, 0),
TYPE_RID            : RID(),
TYPE_SIGNAL         : null,
TYPE_STRING         : '',
TYPE_STRING_NAME    : &'',
TYPE_TRANSFORM2D    : Transform2D.IDENTITY,
TYPE_TRANSFORM3D    : Transform3D.IDENTITY,
TYPE_VECTOR2        : Vector2.ZERO,
TYPE_VECTOR2I       : Vector2i.ZERO,
TYPE_VECTOR3        : Vector3.ZERO,
TYPE_VECTOR3I       : Vector3i.ZERO,
TYPE_VECTOR4        : Vector4.ZERO,
TYPE_VECTOR4I       : Vector4i.ZERO,
```

## Doubling a Script
To double a script just give it class name or a loaded script.
``` gdscript
# If your script has a class_name clause, just use that.
var doubled_script = double(MyClassWithClassName).new()


# Other wise you can do the following:
var MyScript = load('res://my_script.gd')

# Load the doubled object.
var DoubledMyScript = double(MyScript)

# Create an instance of a doubled object
var doubled_script = DoubledMyScript.new()
# or
var doubled_script = double(MyScript).new()

```


## Doubling Inner Classes
Inner Classes cannot be automatically detected and therefore must be registered with GUT before they can be doubled.  You do this by calling `register_inner_classes(Foo)`.  You only have to do this once per script/scene that contains Inner Classes, so it is best to call it in `before_all` or a pre-hook script.  Registering multiple times does nothing.  Failing to call `register_inner_classes` will result in a GUT error and a runtime error.

```gdscript
# Given that SomeScript contains the class InnerClass that
# you wish to double:
var SomeScript = load('res://some_script.gd')

func before_all():
    register_inner_classes(SomeScript)

func test_foo():
    var dbl = double(SomeScript.InnerClass).new()
```

If you reuse doubles of the same inner classes across several tests, it may be easier to register them once in a [Pre-Run Hook](Hooks.md#pre-run-hook) so that you don't have to register them in every test you write.  This can be achieved by calling `register_inner_classes` during your pre-run hook like so:

```gdscript
extends GutHookScript

# Given that SomeScript contains the class InnerClass that
# you wish to double:
var SomeScript = load('res://some_script.gd')

func run():
    register_inner_classes(SomeScript)
```

This approach was used to make tests cleaner and less susceptible to typos.  If Godot adds meta data to inner classes that point back to the source script, then `register_inner_classes` can be removed later and no other changes will need to be made.


## Doubling a Scene
A doubled version of your scene is created along with a double of its script.  The doubled scene is altered to load the doubled script instead of the original.  A reference to the newly doubled scene is returned.  You can call `instantiate` on the returned reference.

``` gdscript
var MyScene = load('res://my_scene.tscn')

var DoubledScene = double(MyScene)

# Create an instance
var doubled_scene = DoubledScene.instantiate()
# or
var doubled_scene = double(MyScene).instantiate()
```


## Doubling Scripts with Static Methods
Currently you cannot double static methods.  In fact if you try to double a class with a static method then you will get an error that looks similar to:
```
Parser Error: Function signature doesn't match the parent. Parent signature is: 'Variant foo()'.
```
As of now, GUT does not have the ability to detect static methods in the code.  As a workaround there is the `ignore_method_when_doubling` method.  This method takes in a variant as the first parameter and a method name as the second.  The first parameter can be a path to a script, a path to a scene, a loaded script, or a loaded scene.

Calling this method will prevent GUT from trying to make a stubbed out version of the method in the generated double allowing you to successfully double your classes that contain static methods.

These ignored methods are cleared after each test is ran to avoid any unexpected results in your tests, so you may want to add this call to your `before_each`.

There's more info and examples on this method on the [[Methods|Asserts-and-Methods]] page.


## Doubled method default parameters
GUT stubs all parameters in doubled user methods to be `null`.  This is because Godot only provides defaults for built-in methods.  When using Partial Doubles or stubbing a method `to_call_super`, `null` can get passed around when you wouldn't expect it causing errors such as `Invalid operands 'int' and 'Nil'`.  See the "Stubbing Method Parameter Defaults" in [Stubbing](Stubbing) for a way to stub method default values.


## Methods with varargs and NativeScript parameter mismatches
Some methods provided by Godot can contain and endless list of parameters (varargs).  Trying to call one of these methods on a double can result in runtime errors due to a parameter mismatch.  See the sections in [Stubbing](Stubbing) that address parameters.

GUT can detect these vararg parameters and will stub the doubled method to accept 10 values which are all defaulted to `null`.

For example, the signature for Node's `rpc_id` function is:
``` gdscript
Error rpc_id ( int peer_id, StringName method, ... ) vararg
```
Here the `...` is the placeholder for the vararg parameter.  When GUT encounters this kind of signature it will generate the following:
```gdscript
func rpc_id (peer_id, method, arg1=null, arg2=null, arg3=null, arg4=null, arg5=null, arg6=null, arg7=null, arg8=null, arg9=null, arg10=null)
```

You can change the number of arguments passed and their default by [stubbing](Stubbing) parameters.


## Doubling Built-In/Base Objects
You can `double` built-in objects that are not inherited by a script such as a `Node2D` or a `Raycast2D`.  These doubles are always created using the Doubling Strategy of `INCLUDE_NATIVE` (see [Double-Strategy](Double-Strategy)).  Be sure to read the [Double-Strategy](Double-Strategy), there are some gotchas and issues with this.

For example you can `double` or `partial_double` like this:
``` gdscript
var doubled_node2d = double(Node2D).new()
stub(doubled_node2d, 'get_position').to_return(-1)

var partial_doubled_raycast = partial_double(Raycast2D).new()
```


## Where to next?
* [Stubbing](Stubbing)
* [Spies](Spies)
* [Partial-Doubles](Partial-Doubles)
* [Double-Strategy](Double-Strategy)
