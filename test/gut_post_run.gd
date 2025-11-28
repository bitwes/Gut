extends  'res://addons/gut/hook_script.gd'


func run():
	print('!! --- post-run script --- !!')
	var oc = GutUtils.OrphanCounter.new()
	oc.record_orphans("post_run")
	oc.log_all()
	print('!!                         !!')