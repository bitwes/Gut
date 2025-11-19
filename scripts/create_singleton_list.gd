extends SceneTree
# Used to generate:
# 	- res://addons/gut/godot_singletons.gd
#	- List of singletons for Singleton-Doubling.md
# The data is pulled from a text file which contains the list of singletons
# copied from Godot's @GlobalScope page.  It was easier to spend 5x the time
# making this than it was to just manually edit this stuff for each Godot
# release.
const SINGLETON_LIST_PATH = "res://templates/singleton_list.txt"
const GODOT_SINGLETONS_PATH = "res://addons/gut/godot_singletons.gd"

var blacklist = [
	# I don't think this can be doubled unless we are running in the editor.
	"EditorInterface",
]

var name_replacements = {
	# On mac the class name is IPUnix, but the singleton is IP.
	'IPUnix':'IP',
}

func _parse_singleton_list():
	var list_text = FileAccess.get_file_as_string(SINGLETON_LIST_PATH)
	var lines = list_text.split("\n")
	var singleton_names = []
	for line in lines:
		line = line.strip_edges()
		if(!line.begins_with("#") and line != '' and !singleton_names.has(line)):
			singleton_names.append(line)
	return singleton_names


func _write_godot_singletons_script():
	var names = _parse_singleton_list()
	var singleton_text = ""
	for name in names:
		if(singleton_text != ''):
			singleton_text += ",\n\t"
		if(blacklist.has(name)):
			singleton_text += "# excluded: " + name
		else:
			singleton_text += name

	var script_text = """
# This file is auto-generated as part of the release process.  GUT maintainers
# should not change this file manually.
static var class_ref = [
	{singletons}
]
static var names = []
static func _static_init():
	for entry in class_ref:
		names.append(entry.get_class())
"""
	script_text = script_text.format({"singletons":singleton_text})
	var file = FileAccess.open(GODOT_SINGLETONS_PATH, FileAccess.WRITE)
	file.store_string(script_text)
	file.close()

	var Loaded = ResourceLoader.load(GODOT_SINGLETONS_PATH, "", ResourceLoader.CACHE_MODE_REPLACE)
	if(Loaded == null):
		push_error("Could not load " + GODOT_SINGLETONS_PATH)
		print(script_text)
	else:
		print(Loaded.class_ref)
		print("File created.")


func _get_doc_link(sname : String):
	var base = &"https://docs.godotengine.org/en/stable/classes/class_"
	return str(base, sname.to_lower(), '.html')


# Eligible Singletons list in Doubling-Singletons.md
func _double_singletons_md_file_list():
	ResourceLoader.load(GODOT_SINGLETONS_PATH, "", ResourceLoader.CACHE_MODE_REPLACE)
	print("")
	var text = ""
	GutUtils.GodotSingletons.names.sort()
	for s in GutUtils.GodotSingletons.names:
		var n = name_replacements.get(s, s)
		text += str("* [", n, '](', _get_doc_link(n), ")\n")
	return text


func _init() -> void:
	_write_godot_singletons_script()
	print(_double_singletons_md_file_list())
	quit()