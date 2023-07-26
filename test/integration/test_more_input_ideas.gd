extends GutTest

class SuperButton:
    extends Button

    func p(s1='', s2='', s3='', s4='', s5='', s6=''):
        print(s1, s2, s3, s4, s5, s6)

    func pevent(txt, event):
        if(event is InputEventMouse):
            print(txt, ':  ', event.position, event.global_position)
        else:
            print(txt, ':  ', event)

    # func _gui_input(event):
    #     p('gui:      ', event)

    # func _input(event):
    #     p('input:     ', event)

    # func _unhandled_input(event):
    #     p('unhandled:  ', event)


class DraggableButton:
    extends SuperButton

    var _mouse_down = false

    func _gui_input(event):
        # super._gui_input(event)
        if(event is InputEventMouseButton):
            _mouse_down = event.pressed
            print('!! down/up')
        elif(event is InputEventMouseMotion and _mouse_down):
            position += event.relative
            print('moved')




func _print_emitted_signals(thing):
    var signals = _signal_watcher.get_signals_emitted(thing)
    signals.sort()
    print(thing, '::Signals')
    GutUtils.pretty_print(signals)



func test_drag_something():
    var btn = DraggableButton.new()
    watch_signals(btn)
    btn.size = Vector2(100, 100)
    btn.position = Vector2(50, 50)
    add_child_autofree(btn)

    # works with Input and btn, btn does not fire signals, Input seems to be
    # having some trouble firigin the button up event.
    var sender = InputSender.new(Input)
    sender.mouse_warp = true

    sender.mouse_left_button_down(btn.position + Vector2(10, 10)).wait(.1)
    sender.mouse_motion(btn.position + Vector2(10, 10))
    for i in range(10):
        await sender.mouse_relative_motion(Vector2(10, 10)).wait(.1).idle
        print('-- ', btn.position, ' --')

    await sender.mouse_left_button_up(btn.position + Vector2(10, 10))\
        .wait(.5).idle
    # await wait_for_signal(sender.idle, 10)
    _print_emitted_signals(btn)

    assert_signal_emitted(btn, 'button_down')
    assert_signal_emitted(btn, 'button_up')
    assert_ne(btn.position, Vector2(50, 50), 'has moved')
    assert_false(btn._mouse_down, 'button mouse down')



#     50 ->|         |<- 150
func test_clicking_things_with_input_as_receiver():
    var btn = SuperButton.new()
    watch_signals(btn)
    btn.size = Vector2(100, 100)
    btn.position = Vector2(50, 50)
    add_child_autofree(btn)

    var sender = InputSender.new(Input)
    sender.mouse_warp = true

    var start_pos = Vector2i(25, 75)
    for i in 15:
        var new_pos = start_pos + Vector2i(i * 10, 0)
        await sender.wait(.1)\
            .mouse_left_button_down(new_pos)\
            .hold_for(.1)\
            .wait(.1).idle

    _print_emitted_signals(btn)
    assert_signal_emitted(btn, 'pressed')
    assert_signal_emitted(btn, 'button_down')
    assert_signal_emitted(btn, 'button_up')
    assert_signal_emitted(btn, 'gui_input')

    # print("\n----move the mouse manually if you want ----\n")
    # await wait_seconds(5)
    # print(_signal_watcher.get_signals_emitted(btn))



func test_clicking_things_with_button_as_receiver():
    var btn = SuperButton.new()
    watch_signals(btn)
    btn.size = Vector2(100, 100)
    btn.position = Vector2(50, 50)
    add_child_autofree(btn)

    var sender = InputSender.new(btn)
    sender.mouse_warp = true

    var start_pos = Vector2i(25, 75)
    for i in 15:
        var new_pos = start_pos + Vector2i(i * 10, 0)
        await sender.wait(.1)\
            .mouse_left_button_down(new_pos)\
            .hold_for(.1)\
            .wait(.1).idle

    _print_emitted_signals(btn)
    assert_signal_emitted(btn, 'pressed')
    assert_signal_emitted(btn, 'button_down')
    assert_signal_emitted(btn, 'button_up')
    assert_signal_emitted(btn, 'gui_input')

