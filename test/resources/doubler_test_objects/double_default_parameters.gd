func return_passed(p1='a', p2='b'):
    print('** super called **')
    return str(p1, p2)

func call_me(p1, p2 = 2):
    return str('called with ', p1, ', ', p2)

func call_call_me(p1):
    return call_me(p1)
