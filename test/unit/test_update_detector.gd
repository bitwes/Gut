extends GutTest


var UpdateDetector = GutUtils.UpdateDetector

var _sample_parsed_data = {
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

func get_sample_data():
	return _sample_parsed_data.duplicate(true)


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
	ud.parse_version_data(get_sample_data())
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
	ud.parse_version_data(get_sample_data())
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
	if(is_failing()):
		gut.p(str("Issues\n", ud.data_issues))


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
	ud.parse_version_data(get_sample_data())
	assert_eq(ud.get_gut_version_for_godot_version("3.6.7"), "13.2.0")


func test_when_godot_version_not_found_branches_is_checked():
	var ud = autofree(UpdateDetector.new())
	ud.parse_version_data(get_sample_data())
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
	ud.parse_version_data(get_sample_data())
	assert_true(ud.is_in_asset_library("99.0"))


func test_is_in_asset_library_returns_false_for_gut_version_not_in_entry():
	var ud = autofree(UpdateDetector.new())
	ud.parse_version_data(get_sample_data())
	assert_false(ud.is_in_asset_library("22.0"))


func test_if_asset_library_is_missing_is_in_asset_library_returns_false():
	var ud = autofree(UpdateDetector.new())
	var data = get_sample_data().duplicate()
	data.erase("asset_library")
	ud.parse_version_data(data)
	assert_false(ud.is_in_asset_library("99.0"))


class TestFetch:
	extends GutTest

	var _sample_parsed_data = {
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
		}
	}

	func get_sample_data():
		return _sample_parsed_data.duplicate(true)


	var UpdateDetector = GutUtils.UpdateDetector

	func before_each():
		gut.file_delete(UpdateDetector.REMOTE_FILE_PATH)


	func _create_update_detector():
		var to_return = partial_double(UpdateDetector).new()
		var d_http_request = partial_double(HTTPRequest).new()

		add_child_autofree(to_return)
		to_return._http_request.free()
		to_return._setup_http_request(d_http_request)

		return to_return

	func _data_as_pba(data=get_sample_data()):
		return JSON.stringify(data).to_utf8_buffer()


	func test_when_rc_200_returned_file_written():
		var ud = _create_update_detector()
		stub(ud.fetch_remote_file).to_do_nothing()
		ud._http_request.request_completed.emit('result', 200, '', _data_as_pba())
		assert_file_exists(ud.REMOTE_FILE_PATH)


	func test_when_rc_200_not_returned_file_not_written():
		var ud = _create_update_detector()
		stub(ud.fetch_remote_file).to_do_nothing()
		ud._http_request.request_completed.emit('result', 300, '', _data_as_pba())
		assert_file_does_not_exist(ud.REMOTE_FILE_PATH)
		assert_push_error("Response code")


	func test_when_rc_200_data_is_parsed():
		var ud = _create_update_detector()
		stub(ud.fetch_remote_file).to_do_nothing()
		ud._http_request.request_completed.emit('result', 200, '',
			JSON.stringify(get_sample_data()).to_utf8_buffer())
		assert_eq(ud.parsed_data, get_sample_data())


	func test_when_there_issues_with_the_data_the_file_is_not_written():
		var ud = _create_update_detector()
		var data = get_sample_data()
		data.erase('asset_library')
		data = JSON.stringify(data).to_utf8_buffer()

		ud._http_request.request_completed.emit('result', 200, '', data)
		assert_file_does_not_exist(ud.REMOTE_FILE_PATH)
		assert_push_error("nvalid version data")


	func test_when_there_are_issues_with_the_data_parsed_data_is_empty():
		var ud = _create_update_detector()
		var data = get_sample_data()
		data.erase('asset_library')
		data = JSON.stringify(data).to_utf8_buffer()

		ud._http_request.request_completed.emit('result', 200, '', data)
		assert_eq(ud.parsed_data, {})
		assert_push_error("nvalid version data")


	func test_when_json_is_invalid_it_is_an_issue():
		var ud = _create_update_detector()
		var data = get_sample_data()
		data.erase('asset_library')
		data = "{invalid json}".to_utf8_buffer()

		ud._http_request.request_completed.emit('result', 200, '', data)
		assert_push_error("Invalid JSON")


	func test_when_json_is_invalid_dowanlod_signal_emitted():
		var ud = _create_update_detector()
		watch_signals(ud)
		var data = get_sample_data()
		data.erase('asset_library')
		data = "{invalid json}".to_utf8_buffer()

		ud._http_request.request_completed.emit('result', 200, '', data)
		assert_signal_emitted(ud.download_completed)
		assert_push_error("Invalid JSON")


	func test_fetched_data_is_written_with_fetch_timestamp():
		var ud = _create_update_detector()
		stub(ud.fetch_remote_file).to_do_nothing()
		ud._http_request.request_completed.emit('result', 200, '', _data_as_pba())

		var json_text = FileAccess.get_file_as_string(ud.REMOTE_FILE_PATH)
		var json = JSON.parse_string(json_text)

		assert_has(json, 'fetch_timestamp')




class TestCheckForUpdateWithFetch:
	extends GutTest


	var _sample_parsed_data = {
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
		}
	}

	func before_each():
		gut.file_delete(UpdateDetector.REMOTE_FILE_PATH)

	func get_sample_data():
		return _sample_parsed_data.duplicate(true)

	func _create_update_detector():
		var to_return = partial_double(UpdateDetector).new()
		var d_http_request = partial_double(HTTPRequest).new()

		add_child_autofree(to_return)
		to_return._http_request.free()
		to_return._setup_http_request(d_http_request)

		return to_return


	var UpdateDetector = GutUtils.UpdateDetector

	func test_it_fetches_data_by_default():
		var ud = _create_update_detector()
		stub(ud.fetch_remote_file).to_do_nothing()

		ud.check_for_update_with_fetch()
		assert_called(ud.fetch_remote_file)


	func test_when_last_fetch_is_not_later_than_min_fetch_time_fetch_is_not_called():
		var ud = _create_update_detector()
		stub(ud.fetch_remote_file).to_do_nothing()
		ud.min_fetch_wait = 60 * 60 * 24 * 10_000 # ten thousand days

		var fake_last_fetch = get_sample_data()
		fake_last_fetch.fetch_timestamp = Time.get_unix_time_from_system()
		GutUtils.write_file(ud.REMOTE_FILE_PATH, JSON.stringify(fake_last_fetch))

		ud.check_for_update_with_fetch()
		assert_not_called(ud.fetch_remote_file)


	func test_when_last_fetch_outside_bounds_then_fetch_is_called():
		var ud = _create_update_detector()
		stub(ud.fetch_remote_file).to_do_nothing()
		ud.min_fetch_wait = 0

		var fake_last_fetch = get_sample_data()
		fake_last_fetch.fetch_timestamp = Time.get_unix_time_from_system() - (60 * 60)
		GutUtils.write_file(ud.REMOTE_FILE_PATH, JSON.stringify(fake_last_fetch))

		ud.check_for_update_with_fetch()
		assert_called(ud.fetch_remote_file)


	func test_check_for_update_with_fetch_emits_updated_upon_completion():
		var ud = _create_update_detector()
		stub(ud.fetch_remote_file).to_call(func():
			ud.download_completed.emit.call_deferred())
		ud.check_for_update_with_fetch()
		await wait_for_signal(ud.updated, 2)
		assert_signal_emitted(ud.updated)


	func test_check_for_update_with_fetch_can_be_forced_to_fetch():
		var ud = _create_update_detector()
		stub(ud.fetch_remote_file).to_do_nothing()
		ud.min_fetch_wait = 60 * 60 * 24 * 10_000 # ten thousand days

		var fake_last_fetch = get_sample_data()
		fake_last_fetch.fetch_timestamp = Time.get_unix_time_from_system()
		GutUtils.write_file(ud.REMOTE_FILE_PATH, JSON.stringify(fake_last_fetch))

		ud.check_for_update_with_fetch(true)
		assert_called(ud.fetch_remote_file)


