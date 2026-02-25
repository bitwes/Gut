extends GutTest


var UpdateDetector = GutUtils.UpdateDetector

var sample_parsed_data = {
    "releases":{
		"99.0":{
			"godot_min":"9.0.0",
			"godot_max":"9999"
		},
		"13.2.0":{
			"godot_min":"3.6.5",
			"godot_max":"3.999",
		},
		"13.1.0":{
			"godot_min":"3.6.0",
			"godot_max":"3.999",
		},
		"13.0.0":{
			"godot_min":"3.0.0",
			"godot_max":"3.5.0",
		},
		"12.0":{
			"godot_min":"2.0",
			"godot_max":"2.999"
		},
		"11.0":{
			"godot_min":"1.0",
			"godot_max":"1.999"
		}
	}
}


func test_can_make_one():
	var ud = UpdateDetector.new()
	assert_not_null(ud)


var _vdata = ParameterFactory.named_parameters([
	'godot_version', 'expected_gut_version'
],[
	["1.0", "11.0"],
	["2.0", "12.0"],
	["3.0.0", "13.0.0"],
	["3.4.1", "13.0.0"],
	["3.6.0", "13.1.0"],
	["3.6.4", "13.1.0"],
	["3.6.5", "13.2.0"],
	["3.6.7", "13.2.0"],

	["9", "99.0"],
	["99", "99.0"],
	["999", "99.0"],

	["0.0.1", "0.0.0"],
	["999999", "0.0.0"]
])
func test_get_recommented_gut_version_from_sample_data(data=use_parameters(_vdata)):
	var ud = UpdateDetector.new()
	ud.parse_version_data(sample_parsed_data, "11.0", data.godot_version)
	assert_eq(ud.new_version, data.expected_gut_version, str('rec version for ', data.godot_version))


var _valid_data = ParameterFactory.named_parameters([
	'gut_version', 'godot_version', 'expected'
],[
	["11.0", "1.0.0", true],
	["11.0", "2.0", false]
])
func test_is_gut_version_valid_for_godot_version(data=use_parameters(_valid_data)):
	var ud = UpdateDetector.new()
	ud.parse_version_data(sample_parsed_data, data.gut_version, data.godot_version)
	assert_eq(ud.is_supported, data.expected, str(data.gut_version, ' valid for ', data.godot_version))


func test_parse_data_returns_dictionary():
	var ud = UpdateDetector.new()
	var data = """{
		"releases":{
			"99.0":{
				"godot_min":"9.0.0",
				"godot_max":"9999"
			},
		}
	}"""

	ud.parse_version_data(data, "99.0", "9.0.1")
	assert_typeof(ud.parsed_data, TYPE_DICTIONARY)


func test_missing_godot_min_listed_as_issue():
	var ud = UpdateDetector.new()
	var data = """{
		"releases":{
			"99.0":{
				"godot_max":"9999"
			}
		}
	}"""
	ud.parse_version_data(data, "99.0", "9.0.1")
	assert_eq(ud.data_issues.size(), 1)


func test_missing_godot_max_listed_as_issue():
	var ud = UpdateDetector.new()
	var data = """{
		"releases":{
			"99.0":{
				"godot_min":"9.0.0",
			}
		}
	}"""
	ud.parse_version_data(data, "99.0", "9.0.1")
	assert_eq(ud.data_issues.size(), 1)


func test_missing_releases_listed_as_issue():
	var ud = UpdateDetector.new()
	var data = "{}"
	ud.parse_version_data(data, "99.0", "9.0.1")
	assert_eq(ud.data_issues.size(), 1)


func test_when_gut_version_not_found():
	var ud = UpdateDetector.new()
	ud.parse_version_data(sample_parsed_data, "77.0", "3.6.7")
	assert_eq(ud.data_issues.size(), 1)
	assert_eq(ud.new_version, "13.2.0")