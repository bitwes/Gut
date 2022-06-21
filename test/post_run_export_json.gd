extends  'res://addons/gut/hook_script.gd'

var ResultExporter = load('res://addons/gut/result_exporter.gd')

func run(): # called automatically by Gut
	var exporter = ResultExporter.new()

	var filename = 'user://logs/gut_results'
	filename += str("_", OS.get_unix_time(), ".json")

	var f_result = exporter.write_json_file(gut, filename)
	if(f_result == OK):
		gut.p(str("Results saved to ", filename))
