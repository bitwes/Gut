extends SceneTree

func print(p1='', p2 = '', p3='', p4='', p5=''):
    super.print('custom_print:  ', p1, p2, p3, p4, p5)


func _init():
    var methods = get_method_list()
    var sorted_names = []
    for i in range(methods.size()):
        sorted_names.append(methods[i]['name'])
    sorted_names.sort()
    print(sorted_names)
    print(print('hello world'))
    var ref = funcref(self, 'print')
    print(ref, ' = ', ref.is_valid())

    ref.call_func('from ref')
    quit()

