
# This file is auto-generated as part of the release process.  GUT maintainers
# should not change this file manually.
static var class_ref = [
	AudioServer,
	CameraServer,
	ClassDB,
	DisplayServer,
	# excluded: EditorInterface,
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
	NavigationServer2DManager,
	NavigationServer3D,
	NavigationServer3DManager,
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
static var names = []
static func _static_init():
	for entry in class_ref:
		names.append(entry.get_class())
