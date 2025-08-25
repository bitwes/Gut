@tool
extends Node2D

class Eyeball:
	extends Node2D
	
	var _color_tween : Tween
	var _size_tween : Tween
	var sprite : Sprite2D = null
	var default_position = Vector2(0, 0)
	var move_radius = 25
	var move_center = Vector2(0, 0)
	var default_color = Color(0.31, 0.31, 0.31)
	var _color = default_color :
		set(val):
			_color = val
			queue_redraw()
	var color = _color : 
		set(val):
			_start_color_tween(_color, val)
		get(): return _color
		
	var default_size = 70
	var _size = default_size :
		set(val):
			_size = val
			queue_redraw()
	var size = _size :
		set(val):
			_start_size_tween(_size, val)
		get(): return _size


	func _init(node):
		sprite = node
		default_position = sprite.position
		move_center = sprite.position
		# hijack the original sprite, because I want to draw it here but keep
		# the original in the scene for layout.
		position = sprite.position
		sprite.get_parent().add_child(self)
		sprite.visible = false
	
	
	func _start_color_tween(old_color, new_color):
		if(_color_tween != null and _color_tween.is_running()):
			_color_tween.kill()
		_color_tween = create_tween()
		_color_tween.tween_property(self, '_color', new_color, .3).from(old_color)
		_color_tween.play()
		
		
	func _start_size_tween(old_size, new_size):
		if(_size_tween != null and _size_tween.is_running()):
			_size_tween.kill()
		_size_tween = create_tween()
		_size_tween.tween_property(self, '_size', new_size, .3).from(old_size)
		_size_tween.play()


	func _draw() -> void:
		draw_circle(Vector2.ZERO, size, color, true, -1, true)
	
	
	func update_for_mouse_position(local_pos):
		var dir = position.direction_to(local_pos)
		var dist = position.distance_to(local_pos)
		position += dir * min(dist, move_radius)
		position.x = clamp(position.x, move_center.x - move_radius, move_center.x + move_radius)
		position.y = clamp(position.y, move_center.y - move_radius, move_center.y + move_radius)


	func reset():
		color = default_color
		size = default_size




# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
@export var active = false : 
	set(val):
		active = val
		if(!active and is_inside_tree()):
			left_eye.position = left_eye.default_position
			right_eye.position = right_eye.default_position


@onready var left_eye : Eyeball = Eyeball.new($BaseLogo/LeftEye)
@onready var right_eye : Eyeball = Eyeball.new($BaseLogo/RightEye)

@onready var _reset_timer = $ResetTimer

func _debug_ready():
	position = Vector2(500, 500)


func _ready():
	if(get_parent() == get_tree().root):
		_debug_ready()

	left_eye.move_center.x -= 20
	right_eye.move_center.x += 10


func _process(_delta):
	if(active):
		left_eye.update_for_mouse_position(get_local_mouse_position())
		right_eye.update_for_mouse_position(get_local_mouse_position())


func _on_reset_timer_timeout() -> void:
	left_eye.reset()
	right_eye.reset()


func eye_scale(left, right=left):
	left_eye.size = left_eye.default_size * left	
	right_eye.size = right_eye.default_size * right
	_reset_timer.start()
	

func default_eye_size():
	left_eye.size = left_eye.default_size
	right_eye.size = right_eye.default_size


func eye_color(left, right=left):
	left_eye.color = left
	right_eye.color = right
	_reset_timer.start()


func default_eye_color():
	left_eye.color = left_eye.default_color
	right_eye.color = right_eye.default_color
