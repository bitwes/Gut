extends SceneTree


class Awaiter:
    extends Node

    func might_await(should):
        if(should):
            print('awaiting')
            await get_tree().create_timer(.5).timeout
            print('awaited')
        else:
            print('not awaiting')

        return should

    func call_might_wait(should):
       return await might_await(should)



func _init():
    print('hello world')
    var awaiter = Awaiter.new()
    get_root().add_child(awaiter)
    # awaiter.call_might_wait(true)
    print('done')

    print(Awaiter.new().get_method_list())
    quit()