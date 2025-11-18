extends SceneTree
# Used to generate documentation and other lists as the list of singletons
# changes.


var name_replacements = {
	# On mac the class nam eis IPUnix, but the singleton is IP.
	'IPUnix':'IP'
}

func _get_doc_link(sname : String):
	var base = &"https://docs.godotengine.org/en/stable/classes/class_"
	return str(base, sname.to_lower(), '.html')


# Eligible Singletons list in Doubling-Singletons.md
func _double_singletons_md_file_list():
	var text = ""
	GutUtils.singleton_names.sort()
	for s in GutUtils.singleton_names:
		var n = name_replacements.get(s, s)
		text += str("* [", n, '](', _get_doc_link(n), ")\n")
	return text


func _init() -> void:
	print(_double_singletons_md_file_list())
	quit()