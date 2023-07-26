* Test fix for mouse up not being detected
* Add "drag" input helper
* Track all mouse movements so the button event generators do not need to get positions if you don't want to send one.
* release_all should return self so you can call it in a string of things.
* Add a "click" input helper
* ! cannot seem to simulate a mouse_entered or mouse_exited, this might have to be fired manually.
* Add "warp_mouse" option to move the mouse position with all mouse events.
* clear method should probably reset the mouse position
* mouse_relative_motion does not take into account button presses, only previous mouse motions.  If mouse button events didn't have to worry about a position this would be cleaner as you could move the mouse, then click instead of having to move and click with the same calculated position for the next call to relative motion to work right.
* Maybe there should be helpers to make events that are relative to a control for position and global_position.  Though the events stated that it mostly had to do with viewports, and not controls.
* when mouse warp is disabled, drawing a fake mouse or mouse position indicator might be helpful.