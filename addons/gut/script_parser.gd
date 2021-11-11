extends Object
class_name ScriptParser

var code_tree: Dictionary = {} setget nosetter

var rem_func: RegEx = null
var rem_class: RegEx = null

func nosetter(_value: Dictionary) -> void:
	pass

func _init() -> void:
	rem_class = RegEx.new()
	rem_func = RegEx.new()
	rem_class.compile("^class\\s+(?<class_name>\\w+)\\:")
	rem_func.compile("^\\s*func\\s*(?<func_name>\\w+)\\s*\\(")

func parse(script_body: String) -> void:
	var lines: Array = script_body.split("\n")
	var cur_class: String = ""
	var lineNo: int = 0
	
	code_tree["self"] = {}
	
	for line in lines:
		lineNo += 1
		var rmatch = rem_class.search(line)
		if rmatch:
			if cur_class == "":
				cur_class = rmatch.get_string("class_name")
				code_tree[cur_class] = {}
		else:
			rmatch = rem_func.search(line)
			if rmatch:
				if line.begins_with("func"):
					cur_class = ""
				
				if cur_class == "":
					code_tree["self"][rmatch.get_string("func_name")] = lineNo
				else:
					code_tree[cur_class][rmatch.get_string("func_name")] = lineNo
