extends SceneTree

# -----------------------------------------------------------------------------
# I checked all the Singletons listed in @GlobalScope and they all inherit from
# Object and nothing else.
#
# -----------------------------------------------------------------------------

var ObjectInspector = load("res://scratch/object_inspector.gd")
# Created from @GlobalScope properties documentation
var all_singletons = [
	AudioServer,
	CameraServer,
	ClassDB,
	DisplayServer,
	EditorInterface,
	Engine,
	EngineDebugger,
	GDExtensionManager,
	Geometry2D,
	Geometry3D,
	IP,
	Input,
	InputMap,
	JavaClassWrapper,
	JavaScriptBridge,
	Marshalls,
	NativeMenu,
	NavigationMeshGenerator,
	NavigationServer2D,
	NavigationServer3D,
	OS,
	Performance,
	PhysicsServer2D,
	PhysicsServer2DManager,
	PhysicsServer3D,
	PhysicsServer3DManager,
	ProjectSettings,
	RenderingServer,
	ResourceLoader,
	ResourceSaver,
	ResourceUID,
	TextServerManager,
	ThemeDB,
	Time,
	TranslationServer,
	WorkerThreadPool,
	XRServer
]

var o_method_index = {}

# I didn't see any difference in the method flags to tell the difference between
# singleton methods and object methods, so this filters out any method that is
# in Object.
func get_only_non_object_methods(thing):
	var to_return = []
	for m in thing.get_method_list():
		if(!o_method_index.has(m.name)):
			to_return.append(m)

	return to_return


func print_singleton_info(s):
	var oi = ObjectInspector.new()

	print("------------------------------------------------------")
	print(s.get_class())
	oi.print_script_info(s)
	print("-- Properties --------------")
	if(s.has_method('get_property_list')):
		oi.print_properties(s.get_property_list(), s)

	print("-- Enums ------------")
	# These also need to have Object's enums filtered out.
	print(ClassDB.class_get_enum_list(s.get_class()))
	for e in ClassDB.class_get_enum_list(s.get_class()):
		print(ClassDB.class_get_enum_constants(s.get_class(), e))

	print("-- Methods --------------")
	for m in get_only_non_object_methods(s):
		oi.print_method_signature(m)


func print_singleton_info_classdb(sname, klass):
	var oi = ObjectInspector.ClassDBInspector.new()
	print("------------------------------------------------------")
	print(sname, "::", klass)
	print("-- Properties --------------")
	oi.print_properties(ClassDB.class_get_property_list(sname), klass)

	print("-- Enums ------------")
	# These also need to have Object's enums filtered out.
	print(ClassDB.class_get_enum_list(sname))
	for e in ClassDB.class_get_enum_list(sname):
		print(ClassDB.class_get_enum_constants(sname, e))

	print("-- Methods --------------")
	oi.print_method_signatures(sname)
	# print(ClassDB.class_get_property_list(sname))


func _init() -> void:
	var o = Object.new()
	var o_methods = o.get_method_list()
	o.free()
	for m in o_methods:
		o_method_index[m.name] = m

	# oi.include_method_flags = true

	print_singleton_info(Time)
	# print_singleton_info(OS)
	# print_singleton_info(AudioServer)
	# for s in all_singletons:
	# 	if(GutUtils.is_instance(s)):
	# 		print("yes")
	# 	else:
	# 		print("     NOPE ", s)
		# print_singleton_info(s)
	# print(EditorInterface)
	# print_singleton_info_classdb("EditorInterface", EditorInterface)


	# print_singleton_info(ClassDB)
	quit()

