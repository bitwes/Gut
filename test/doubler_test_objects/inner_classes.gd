var _value = 1

class InnerA:
	func get_a():
		return 'a'

class InnerB:
	func get_b():
		return 'b'

	class InnerB1:
		func get_b1():
			return 'b1'

class InnerCA:
	extends InnerA

	func get_ca():
		return 'ca'

func get_value():
	return _value

func set_value(val):
	_value = val
