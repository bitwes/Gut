extends GutTest
var UpdateDetector = GutUtils.UpdateDetector

var data = GutUtils.get_file_as_text('res://addons/gut/versions.json')
var ud = UpdateDetector.new()

func before_all():
	ud.parse_version_data(data)


func test_local_versions_file_is_valid():
	assert_eq(ud.data_issues.size(), 0, "no data issues")
	if(is_failing()):
		gut.p(str("Issues:\n", ud.data_issues))
	assert_has(ud.parsed_data.releases, GutUtils.version_numbers.gut_version,
		"current version exists")
