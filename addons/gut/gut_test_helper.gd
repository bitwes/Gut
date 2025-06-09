extends GutTest
class_name GutTestHelper


signal similar_node_detected()


const DEFAULT_WAIT_TIME: float = 10.0

var _input_sender = InputSender.new()


static func get_scene_tree_path(p_node: Node) -> String:
	if !check_is_instance_valid(p_node):
		return ""
	
	var m_remote_viewport: Viewport = get_remote_view_port()
	var m_tree: PoolStringArray = []
	
	var m_node = p_node
	var m_parent
	
	m_tree.push_back(p_node.name)
	
	while m_node != m_remote_viewport:
		m_parent = m_node.get_parent()
		if m_parent == null:
			return "Undefined"
		
		m_tree.push_back(m_parent.name)
		m_node = m_parent
	
	m_tree.invert()
	return "/" + m_tree.join("/")


static func get_remote_view_port() -> Viewport:
	return Engine.get_main_loop().root


static func is_valid_control_node(p_control_node) -> bool:
	if (
		p_control_node == null or
		!is_instance_valid(p_control_node) or
		not (p_control_node is Control)
	):
		return false
	
	return true


static func check_is_instance_valid(p_instance) -> bool:
	if p_instance == null or !is_instance_valid(p_instance):
		return false
	
	return true


func get_node_from_root(p_node_path: String):
	return get_node(NodePath(p_node_path))


func mouse_left_button_click_simulation(p_absolute_node_path: String) -> void:
	var m_receiver = get_node_from_root(p_absolute_node_path)
	
	if !is_valid_control_node(m_receiver):
		var m_err_msg: String = "Not a valid Node Path: " + p_absolute_node_path
		push_error(m_err_msg)
		
		return
	
	var m_local_pos: Vector2 = m_receiver.rect_position + m_receiver.rect_size / 2
	var m_global_pos: Vector2 = m_receiver.get_global_rect().position  + m_receiver.rect_size / 2
	
	if !m_receiver.has_method("_input") and !m_receiver.has_method("_gui_input") and !m_receiver.has_method("_unhandled_input"):
		mouse_left_click_in_global_pos(m_local_pos, m_global_pos)
		return
	
	_input_sender.add_receiver(m_receiver)
	
	_input_sender.mouse_left_button_down(m_local_pos, m_global_pos)
	_input_sender.mouse_left_button_up(m_local_pos, m_global_pos)

 
func mouse_left_click_in_global_pos(p_local_pos: Vector2, p_global_pos: Vector2) -> void:
	var m_input_factory = load("res://addons/gut/input_factory.gd").new()
	
	var m_mouse_left_btn_down: InputEventMouseButton = m_input_factory.mouse_left_button_down(p_local_pos, p_global_pos)
	Input.parse_input_event(m_mouse_left_btn_down)
	
	var m_mouse_left_btn_up: InputEventMouseButton = m_input_factory.mouse_left_button_up(p_local_pos, p_global_pos)
	Input.parse_input_event(m_mouse_left_btn_up)


func clear_input_receiver() -> void:
	_input_sender.clear_receiver()


# This method does not work in android platform
# ToDo: Check in Input.parse_input_event() in android plaform
func screen_touch_input_event(p_absolute_node_path: String) -> void:
	var m_receiver = get_node_from_root(p_absolute_node_path)
	
	if !is_valid_control_node(m_receiver):
		var m_err_msg: String = "Not a valid Node Path: " + p_absolute_node_path
		push_error(m_err_msg)
		
		return
	
	var m_global_pos: Vector2 = m_receiver.get_global_rect().position + m_receiver.rect_size / 2
	
	_input_sender.screen_touch_input_event(m_global_pos)
	_input_sender.screen_touch_removing_input_event()


func wait_until_node_is_added(
	p_target_nodes_abs_path: String,
	p_wait_time: float = DEFAULT_WAIT_TIME
) -> bool:
	yield(yield_for(0.1), YIELD)
	
	var m_required_node = get_node(p_target_nodes_abs_path)
	if m_required_node != null and is_instance_valid(m_required_node):
		return true
	
	# m_main_loop is being used as scene tree
	var m_main_loop = Engine.get_main_loop()
	m_main_loop.connect("node_added", self, "_on_node_added", [p_target_nodes_abs_path])
	
	var m_wait_timer: SceneTreeTimer = get_tree().create_timer(p_wait_time)
	m_wait_timer.connect("timeout", self, "_on_wait_timer_timeout")
	
	# Returns false if signal received from timout
	var m_is_node_found: bool = yield(self, "similar_node_detected")
	
	if m_main_loop.is_connected("node_added", self, "_on_node_added"):
		m_main_loop.disconnect("node_added", self, "_on_node_added")
	
	return m_is_node_found


func _on_node_added(p_new_node, p_node_path: String) -> void:
	var m_current_node_path: String = get_scene_tree_path(p_new_node)
	
	if p_node_path != m_current_node_path:
		return
	
	emit_signal("similar_node_detected", true)


func _on_wait_timer_timeout() -> void:
	emit_signal("similar_node_detected", false)


func pause_server_connection() -> void:
	ServerConnection.close_connections()


func scroll_to_visible_element_to_right(
	p_scroll_container_path: String,
	p_scroll_element_path: String
) -> Dictionary:
	var m_scroll_container = get_node(p_scroll_container_path)
	var m_scroll_element = get_node(p_scroll_element_path)
	
	yield(yield_for(0.1), YIELD)
	
	if (
		m_scroll_container == null or
		not is_instance_valid(m_scroll_container) or
		m_scroll_element == null or
		not is_instance_valid(m_scroll_element)
	):
		return {"status": "invalid_element"}
	
	var min_scroll_ele_x_pos: int = CONFIG.screen_size.x - m_scroll_element.rect_size.x
	
	while m_scroll_element.get_global_rect().position.x > min_scroll_ele_x_pos:
		m_scroll_container.scroll_horizontal += 20
		yield(yield_for(0.1), YIELD)
	
	return {"status": "element_found"}


func get_text_from_label(p_label_path: String):
	var m_label_node = get_node(p_label_path)
	
	if m_label_node == null or not is_instance_valid(m_label_node):
		return null
	
	if m_label_node is Label:
		return m_label_node.text
	elif m_label_node is RichTextLabel:
		return m_label_node.bbcode_text
	else:
		return null


func click(component_key: String, component_paths: Dictionary) -> void:
	var path: String = component_paths[component_key]
	mouse_left_button_click_simulation(path)
	clear_input_receiver()
