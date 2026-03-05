extends GutTest
var UpdateDetector = GutUtils.UpdateDetector

var data = GutUtils.get_file_as_text('res://addons/gut/versions.json')
var ud = null

func before_all():
	ud = UpdateDetector.new()
	add_child(ud)


func after_all():
	ud.free()


func test_local_versions_file_is_valid():
	ud.parse_file(ud.LOCAL_FILE_PATH)
	assert_eq(ud.data_issues.size(), 0, "no data issues")
	if(is_failing()):
		gut.p(str("Issues:\n", ud.data_issues))
	assert_has(ud.parsed_data.releases, GutUtils.version_numbers.gut_version,
		"current version exists")


func test_parsing_remote_data():
	var error = ud.fetch_remote_file()
	if(error == OK):
		await wait_for_signal(ud.download_completed, 5)
		assert_has(ud.parsed_data, 'releases')
	else:
		fail_test("There was an error starting request")
