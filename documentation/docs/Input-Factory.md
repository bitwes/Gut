
# InputFactory
This static class is available when extending `GutTest`.  The methods in this class are simple wrappers to make it a little easier to create instances of the various `InputEvent*` classes.  These are used, under the covers, by (Input Sender)[Mocking-Input].

Usage:
```
extends GutTest

func test_something():
    var event = InputFactory.action_down("jump")
    ...
```


## Methods


### key_down
`key_down(which)`<br>
Returns a "key down" `InputEventKey` event instance.  `which` can be one of the Godot `KEY_*` constants or a character.

### key_up
`key_up(which)`<br>
Returns a "key up" `InputEventKey` event instance.  `which` can be one of the Godot `KEY_*` constants or a character.

### action_up
`action_up(which, strength=1.0)`<br>
Returns a "action up" `InputEventAction` instance.  `which` is the name of the action defined in the Key Map.

### action_down
`action_down(which, strength=1.0)`<br>
Returns a "action down" `InputEventAction` instance.  `which` is the name of the action defined in the Key Map.

### new_mouse_button_event
`new_mouse_button_event(position, global_position, pressed, button_index)`<br>
Returns a `InputEventMouseButton` instance.  See `InputEventMouse` and `InputEventMouseButton` for parameter descriptions.

#### mouse_left_button_down
`mouse_left_button_down(position, global_position=null)`<br>
Returns a "button down" `InputEventMouseButton` for the left mouse button.

### mouse_left_button_up
`mouse_left_button_up(position, global_position=null)`<br>
Returns a "button up" `InputEventMouseButton` for the left mouse button.

### mouse_double_click
`mouse_double_click(position, global_position=null)`<br>
Returns a "double click" `InputEventMouseButton` for the left mouse button.

### mouse_right_button_down
`mouse_right_button_down(position, global_position=null)`<br>
Returns a "button down" `InputEventMouseButton` for the right mouse button.

### mouse_right_button_up
`mouse_right_button_up(position, global_position=null)`<br>
Returns a "button up" `InputEventMouseButton` for the right mouse button.

### mouse_motion
`mouse_motion(position, global_position=null)`
Returns a `InputEventMouseMotion` instance indicating the mouse moved to the position(s) passed.

### mouse_relative_motion
`mouse_relative_motion(offset, last_motion_event=null, speed=Vector2(0, 0))`<br>
Returns a `InputEventMouseMotion` instance indicating the mouse moved `offset` distance from `last_motion_event` at `speed`.  The default `speed` is instant.
