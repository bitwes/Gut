# ------------------------------------------------------------------------------
# It keeps track of the orphans...so this is best name it could ever have.
# ------------------------------------------------------------------------------
class Orphanage:
	const UNGROUPED = "UNGROUPED"
	var orphan_ids = {}
	var oprhans_by_group = {}
	var strutils = GutUtils.Strutils.new()
	# var new_orphans = []

	func _make_group_key(group=null, subgroup=null):
		var to_return = UNGROUPED
		if(group != null):
			to_return = group

		if(subgroup == null):
			to_return += UNGROUPED
		else:
			to_return += str(".", subgroup)

		return to_return

	func _add_orphan_by_group(id, group, subgroup):
		var key = _make_group_key(group, subgroup)
		if(oprhans_by_group.has(key)):
			oprhans_by_group[key].append(id)
		else:
			oprhans_by_group[key] = [id]


	func process_orphans(group=null, subgroup=null):
		var new_orphans = []
		for orphan_id in Node.get_orphan_node_ids():
			if(!orphan_ids.has(orphan_id)):
				new_orphans.append(orphan_id)
				orphan_ids[orphan_id] = {
					"group":GutUtils.nvl(group, UNGROUPED),
					"subgroup":GutUtils.nvl(subgroup, UNGROUPED)
				}
				_add_orphan_by_group(orphan_id, group, subgroup)


		return new_orphans


	func get_orphans(group=null, subgroup=null):
		var key = _make_group_key(group, subgroup)
		return oprhans_by_group.get(key, [])


	# Given the likely size, this was way easier than making a dictionary
	# of dictionaries of arrays.
	func get_all_group_orphans(group):
		var to_return = []
		for key in oprhans_by_group:
			if(key == group or key.begins_with(str(group, '.'))):
				to_return.append_array(oprhans_by_group[key])
		return to_return


	func clean():
		oprhans_by_group.clear()
		for key in orphan_ids.keys():
			if(!is_instance_id_valid(key)):
				orphan_ids.erase(key)
			else:
				_add_orphan_by_group(key, orphan_ids[key].group, orphan_ids[key].subgroup)




# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
var _strutils = GutStringUtils.new()

var orphanage = Orphanage.new()
var logger = GutUtils.get_logger()


func orphan_count() -> int:
	return Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)


func record_orphans(group, subgroup = null):
	var result = orphanage.process_orphans(group, subgroup)
	return convert_instance_ids_to_valid_instances(result)


func convert_instance_ids_to_valid_instances(orphan_ids):
	var to_return = []
	for entry in orphan_ids:
		if(is_instance_id_valid(entry)):
			to_return.append(instance_from_id(entry))
	return to_return


func end_script(script_path, should_log):
	record_orphans(script_path)
	var orphans = orphanage.get_all_group_orphans(script_path)
	if(orphans.size() > 0 and should_log):
		logger.orphan(str(orphans.size(), ' orphans'))


func end_test(script_path, test_name, should_log = true):
	var orphans = record_orphans(script_path, test_name)
	if(orphans.size() > 0 and should_log):
		logger.orphan('Orphans:')
		for o in orphans:
			logger.orphan(str('    * ', _strutils.type2str(o)))


func get_orphans(group, subgroup=null):
	if(subgroup == null):
		return orphanage.get_all_group_orphans(group)
	else:
		return orphanage.get_orphans(group, subgroup)


func get_count() -> int:
	return orphan_count()
	# return orphanage.orphan_ids.size()


func log_all():
	var last_script = ''
	var last_test = ''
	var still_orphaned = 0

	for key in orphanage.orphan_ids:
		var inst = instance_from_id(key)
		if(inst != null and inst is not GutTest):
			var entry = orphanage.orphan_ids[key]
			if(entry.group != last_script):
				logger.log(entry.group)
				last_script = entry.group
			if(entry.subgroup != last_test):
				logger.log(str('    - ', entry.subgroup))
				last_test = entry.subgroup
			logger.log(str('    ', '    * ', _strutils.type2str(inst)))
			still_orphaned += 1

	logger.log(str("\nTotal = ", still_orphaned))


# ##############################################################################
#(G)odot (U)nit (T)est class
#
# ##############################################################################
# The MIT License (MIT)
# =====================
#
# Copyright (c) 2025 Tom "Butch" Wesley
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# ##############################################################################
