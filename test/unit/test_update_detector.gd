extends GutTest


var UpdateDetector = GutUtils.UpdateDetector

var sample_parsed_data = {
	"asset_library":"99.0",
	"branches":{
		"main":{
			"godot_min":"8.0.0",
			"godot_max":"8.999"
		}
	},
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
	ud.free()


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
	var ud = autofree(UpdateDetector.new())
	ud.parse_version_data(sample_parsed_data)
	var v = ud.get_gut_version_for_godot_version(data.godot_version)
	assert_eq(v, data.expected_gut_version, str('rec version for ', data.godot_version))


var _valid_data = ParameterFactory.named_parameters([
	'gut_version', 'godot_version', 'expected'
],[
	["11.0", "1.0.0", true],
	["11.0", "2.0", false]
])
func test_is_gut_version_valid_for_godot_version(data=use_parameters(_valid_data)):
	var ud = autofree(UpdateDetector.new())
	ud.parse_version_data(sample_parsed_data)
	var is_it = ud.is_gut_version_valid(data.gut_version, data.godot_version)
	assert_eq(is_it, data.expected, str(data.gut_version, ' valid for ', data.godot_version))


func test_parse_data_returns_dictionary():
	var ud = autofree(UpdateDetector.new())
	var data = """{
		"asset_library":"x.x",
		"branches":{},
		"releases":{
			"99.0":{
				"godot_min":"9.0.0",
				"godot_max":"9999"
			},
		}
	}"""

	ud.parse_version_data(data)
	assert_typeof(ud.parsed_data, TYPE_DICTIONARY)


func test_missing_godot_min_listed_as_issue():
	var ud = autofree(UpdateDetector.new())
	var data = """{
		"asset_library":"x.x",
		"branches":{},
		"releases":{
			"99.0":{
				"godot_max":"9999"
			}
		}
	}"""
	ud.parse_version_data(data)
	assert_eq(ud.data_issues.size(), 1)


func test_missing_godot_max_listed_as_issue():
	var ud = autofree(UpdateDetector.new())
	var data = """{
		"asset_library":"x.x",
		"branches":{},
		"releases":{
			"99.0":{
				"godot_min":"9.0.0",
			}
		}
	}"""
	ud.parse_version_data(data)
	assert_eq(ud.data_issues.size(), 1)


func test_missing_releases_listed_as_issue():
	var ud = autofree(UpdateDetector.new())
	var data = """{
		"asset_library":"x.x",
		"branches":{}
	}"""

	ud.parse_version_data(data)
	assert_eq(ud.data_issues.size(), 1)


func test_when_gut_version_not_found():
	var ud = autofree(UpdateDetector.new())
	ud.parse_version_data(sample_parsed_data)
	assert_eq(ud.get_gut_version_for_godot_version("3.6.7"), "13.2.0")


func test_when_godot_version_not_found_branches_is_checked():
	var ud = autofree(UpdateDetector.new())
	ud.parse_version_data(sample_parsed_data)
	assert_eq(ud.get_gut_version_for_godot_version("8.0.0"), "main")


func test_missing_branches_entry_is_an_issue():
	var ud = autofree(UpdateDetector.new())
	var data = """{
		"asset_library":"x.x",
		"releases":{
			"99.0":{
				"godot_min":"9.0.0",
				"godot_max":"9999"
			}
		}
	}"""
	ud.parse_version_data(data)
	assert_eq(ud.data_issues.size(), 1)


func test_branches_missing_godot_min_is_an_issue():
	var ud = autofree(UpdateDetector.new())
	var data = """{
		"asset_library":"x.x",
		"releases":{},
		"branches":{
			"some_branch":{
				"godot_max":"9999"
			}
		}
	}"""
	ud.parse_version_data(data)
	assert_eq(ud.data_issues.size(), 1)


func test_branches_missing_godot_max_is_an_issue():
	var ud = autofree(UpdateDetector.new())
	var data = """{
		"asset_library":"x.x",
		"releases":{},
		"branches":{
			"some_branch":{
				"godot_min":"9.0.0",
			}
		}
	}"""
	ud.parse_version_data(data)
	assert_eq(ud.data_issues.size(), 1)

func test_when_gut_version_not_found_is_valid_returns_false():
	var ud = autofree(UpdateDetector.new())
	ud.parse_file(ud.LOCAL_FILE_PATH)
	assert_false(ud.is_gut_version_valid('23432.124231.123234', GutUtils.godot_version_string()))


func test_when_asset_library_entry_is_missing_it_is_an_issue():
	var ud = autofree(UpdateDetector.new())
	var data = """{
		"releases":{},
		"branches":{}
	}"""
	ud.parse_version_data(data)
	assert_eq(ud.data_issues.size(), 1)


func test_is_in_asset_library_returns_true_for_gut_version_in_entry():
	var ud = autofree(UpdateDetector.new())
	ud.parse_version_data(sample_parsed_data)
	assert_true(ud.is_in_asset_library("99.0"))


func test_is_in_asset_library_returns_false_for_gut_version_not_in_entry():
	var ud = autofree(UpdateDetector.new())
	ud.parse_version_data(sample_parsed_data)
	assert_false(ud.is_in_asset_library("22.0"))


func test_if_asset_library_is_missing_is_in_asset_library_returns_false():
	var ud = autofree(UpdateDetector.new())
	var data = sample_parsed_data.duplicate()
	data.erase("asset_library")
	ud.parse_version_data(data)
	assert_false(ud.is_in_asset_library("99.0"))
