const b_ref := preload('res://test/resources/parsing_and_loading_samples/cyclic_ref_class_b.gd')

class CyclicRefAInnerClass:
	var foo = 'bar'

	class CyclicRfAInnerInnerClass:
		var bar = 'foo'

