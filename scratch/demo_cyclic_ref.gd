extends SceneTree



class CyclicRefClass:
	var other_thing = null


func _init() -> void:
	var cyclic_ref_a = CyclicRefClass.new()
	var cyclic_ref_b = CyclicRefClass.new()
	cyclic_ref_a.other_thing = cyclic_ref_b
	cyclic_ref_b.other_thing = cyclic_ref_a

	# cyclic_ref_a.other_thing = null
	# cyclic_ref_b.other_thing = null

	await create_timer(.5).timeout
	quit()