# <div class="warning">This page has not been updated for GUT 9.0.0 or Godot 4.  There could be incorrect information here.</div>
Remember all that stuff I said earlier about not being able to double Godot Built-Ins?  Forget about it...or forget half of it, maybe 45% of it.

You can [spy on](Spies) and stub most of the Built-Ins in Godot if you enable the `FULL` Doubling Strategy. I've enabled this feature in my own game and it didn't crash (I currently have 75 test scripts and 3633 asserts).  As reassuring as that was I'm still not sure that it won't blow up for someone so it is off by default.

The following methods cannot be spied on due to implementation details with either Gut or GDScript.  There might be more.

```
has_method      _draw
get_script      _physics_process
get             _input
_notification   _unhandled_input
get_path        _unhandled_key_input
_enter_tree     _get
_exit_tree      emit_signal
_process        _set
```
## Remember
If you've defined one of these methods in your class then you can double/spy on them just as you normally would.

# Setting the Doubling Strategy
You can set the default strategy from the command line, .gutconfig, or by calling `set_double_strategy` on your Gut instance.

You can also override the default strategy at the Test Script level or for a specific call to `double`.  When set at the script level, it will reset at the end of the script or Inner Test Class.  When passed to `double` it will only take effect for that one double.

### .gutconfig
Valid values are `partial`(default) or `full`
```
"double_strategy":"full"
```

### Command Line
Use the `-gdouble_strategy` option with the values `partial` or `full`
```
-gdouble_strategy=full
```

### Script Level
```
set_double_strategy(DOUBLE_STRATEGY.FULL)
set_double_strategy(DOUBLE_STRATEGY.PARTIAL)
```

### When Calling `double`
Just add another parameter to your call to `double` using the `DOUBLE_STRATEGY` enum.
```
double('res://thing.gd', DOUBLE_STRATEGY.PARTIAL)
double('res://inners.gd', 'InnerA', DOUBLE_STRATEGY.FULL)
double('res://my_scene.tscn', DOUBLE_STRATEGY.PARTIAL)
```
