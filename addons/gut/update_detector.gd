var Vnt = load("res://addons/gut/version_numbers.gd").VerNumTools


var data_issues = []
var parsed_data = {}


func get_gut_version_for_godot_version(godot_v):
	var to_return = "0.0.0"

	for key in parsed_data.releases:
		var entry = parsed_data.releases[key]
		if(Vnt.is_version_gte(godot_v, entry.godot_min) and Vnt.is_version_lte(godot_v, entry.godot_max)):
			return key
			to_return = key

	if(to_return == "0.0.0" and parsed_data.has('branches')):
		for key in parsed_data.branches:
			var entry = parsed_data.branches[key]
			if(Vnt.is_version_gte(godot_v, entry.godot_min) and Vnt.is_version_lte(godot_v, entry.godot_max)):
				return key
				to_return = key

	return to_return


func is_gut_version_valid(gut_v, godot_v):
	var entry = parsed_data.releases[gut_v]
	return Vnt.is_version_gte(godot_v, entry.godot_min) and Vnt.is_version_lte(godot_v, entry.godot_max)


func parse_version_data(data):
	parsed_data = data
	if(typeof(data) == TYPE_STRING):
		parsed_data = JSON.parse_string(data)

	if(parsed_data.has('releases')):
		for key in parsed_data.releases:
			var entry = parsed_data.releases[key]
			if(!entry.has('godot_min')):
				data_issues.append(str(key, ' missing godot_min'))
			if(!entry.has('godot_max')):
				data_issues.append(str(key, ' missing godot_max'))
	else:
		data_issues.append('missing releases entry')

	if(parsed_data.has('branches')):
		for key in parsed_data.branches:
			var entry = parsed_data.branches[key]
			if(!entry.has('godot_min')):
				data_issues.append(str(key, ' missing godot_min'))
			if(!entry.has('godot_max')):
				data_issues.append(str(key, ' missing godot_max'))
	else:
		data_issues.append('missing branches entry')


# func get_update_string(json_string, gut_v, godot_v):
# 	var to_return = "No updates available"

# 	var parsed = parse_version_data(json_string)
# 	if(parsed.issues.size() == 0):
# 		var rec_ver = get_recommended_gut_version(parsed.data, godot_v)
# 		var is_valid_for_godot = is_gut_version_valid_for_godot_version(parsed.data, gut_v, godot_v)
# 	else:
# 		to_return = str("Data has issues:  ", parsed.issues)

# 	return to_return

