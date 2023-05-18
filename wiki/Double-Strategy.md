When creating doubles, GUT will create overrides for all the methods defined in the source script/scene's script.  By default, GUT will also create overrides for all the Native methods from the object in inherits from (`Node2D` for example).  Native methods aren't really supposed to overridden though due to how Godot calls them internally.  This doesn't matter much for Doubles and Partial Doubles since you probably won't be using them in a manner in which the Engine would interact with them directly.  In the rare occassions where the Engine does interact with them, you will not be able to spy on the calls or stub returns since the engine will not be calling the methods defined in the double.

You can change the default behavior by setting the Double Strategy.  You can change the default for all scripts.  You can also set the strategy for a single script or a single Double/Partial Double.

When set to `SCRIPT_ONLY` native methods will not be included in the Double or Partial Double.

# Set the Default Strategy
The default is `INCLUDE_NATIVE`.  You can change the default through the GutPanel or the `.gutconfig.json` file for the command line.

### .gutconfig
Valid values are `SCRIPT_ONLY`(default) or `INCLUDE_NATIVE`
```
"double_strategy":"SCRIPT_ONLY"
```

### Command Line
Use the `-gdouble_strategy` option with the values `INCLUDE_NATIVE` or `SCRIPT_ONLY`
```
-gdouble_strategy='script only' ??? TODO IDK IF THIS WORKS
```

# Overriding the Default
### Script Level
From withing a `GutTest` you can call `set_double_strategy` to change the strategy to use for the script.  This value will be reset to the default after the script has finished.  It's best to use this in `before_all`.
```
set_double_strategy(DOUBLE_STRATEGY.INCLUDE_NATIVE)
set_double_strategy(DOUBLE_STRATEGY.SCRIPT_ONLY)
```

### Set for Single Double
When calling `double` or `partial_double` you can pass an optional parameter to set the double strategy for just that double.
```
double(Foo, DOUBLE_STRATEGY.SCRIPT_ONLY)
double(Bar, DOUBLE_STRATEGY.INCLUDE_NATIVE)
double(MyScene, DOUBLE_STRATEGY.SCRIPT_ONLY)
```