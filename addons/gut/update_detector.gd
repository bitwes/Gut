var Vnt = load("res://addons/gut/version_numbers.gd").VerNumTools


var new_version = "unknown"
var is_supported = false
var data_issues = []
var parsed_data = {}


func _get_recommended_gut_version(vdata, godot_v):
	var to_return = "0.0.0"

	for key in vdata.releases:
		var entry = vdata.releases[key]
		if(Vnt.is_version_gte(godot_v, entry.godot_min) and Vnt.is_version_lte(godot_v, entry.godot_max)):
			return key
			to_return = key

	return to_return


func _is_gut_version_valid_for_godot_version(vdata, gut_v, godot_v):
	var entry = vdata.releases[gut_v]
	return Vnt.is_version_gte(godot_v, entry.godot_min) and Vnt.is_version_lte(godot_v, entry.godot_max)


func parse_version_data(data, gut_v, godot_v):
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

	if(data_issues.size() == 0):
		if(parsed_data.releases.has(gut_v)):
			is_supported = _is_gut_version_valid_for_godot_version(parsed_data, gut_v, godot_v)
		else:
			data_issues.append(str("Unknown GUT version ", gut_v))
		new_version = _get_recommended_gut_version(parsed_data, godot_v)


# func get_update_string(json_string, gut_v, godot_v):
# 	var to_return = "No updates available"

# 	var parsed = parse_version_data(json_string)
# 	if(parsed.issues.size() == 0):
# 		var rec_ver = get_recommended_gut_version(parsed.data, godot_v)
# 		var is_valid_for_godot = is_gut_version_valid_for_godot_version(parsed.data, gut_v, godot_v)
# 	else:
# 		to_return = str("Data has issues:  ", parsed.issues)

# 	return to_return

