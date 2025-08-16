# ------------------------------------------------------------------------------
# It keeps track of the orphans...so this is best name it could ever have.
# ------------------------------------------------------------------------------
class Orphanage:
	const UNGROUPED = "UNGROUPED"
	var orphan_ids = {}
	var oprhans_by_group = {}
	var strutils = GutUtils.Strutils.new()

	# wrapper for stubbing
	func _get_system_orphan_node_ids():
		return Node.get_orphan_node_ids()


	func _make_group_key(group=null, subgroup=null):
		var to_return = UNGROUPED
		if(group != null):
			to_return = group

		if(subgroup == null):
			to_return += str('->', UNGROUPED)
		else:
			to_return += str("->", subgroup)

		return to_return


	func _add_orphan_by_group(id, group, subgroup):
		var key = _make_group_key(group, subgroup)
		if(oprhans_by_group.has(key)):
			oprhans_by_group[key].append(id)
		else:
			oprhans_by_group[key] = [id]


	func process_orphans(group=null, subgroup=null):
		var new_orphans = []
		for orphan_id in _get_system_orphan_node_ids():
			if(!orphan_ids.has(orphan_id)):
				new_orphans.append(orphan_id)
				orphan_ids[orphan_id] = {
					"group":GutUtils.nvl(group, UNGROUPED),
					"subgroup":GutUtils.nvl(subgroup, UNGROUPED),
					"instance":instance_from_id(orphan_id)
				}
				_add_orphan_by_group(orphan_id, group, subgroup)

		return new_orphans


	func get_orphan_ids(group=null, subgroup=null):
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
			var inst = orphan_ids[key].instance
			if(!is_instance_valid(inst) or inst.get_parent() != null and not orphan_ids.has(inst.get_parent().get_instance_id())):
				orphan_ids.erase(key)
			else:
				_add_orphan_by_group(key, orphan_ids[key].group, orphan_ids[key].subgroup)




# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
var _strutils = GutStringUtils.new()

var orphanage : Orphanage = Orphanage.new()
var logger = GutUtils.get_logger()
var autofree = GutUtils.AutoFree.new()
var hide_autofree = false

# returns {instance_id:child_count, instance_id:child_count}
# func _consolidate_orphan_children(orphan_ids):
# 	var to_return = {}

# 	for id in orphan_ids:
# 		var inst = orphanage.orphan_ids[id].instance
# 		var root_parent = null
# 		var trav_node = inst
# 		if(is_instance_valid(inst)):
# 			while(trav_node.get_parent() != null):
# 				root_parent = trav_node.get_parent()
# 				trav_node = root_parent

# 			if(root_parent == null):
# 				to_return[id] = 0
# 			else:
# 				var root_parent_id = root_parent.get_instance_id()
# 				if(to_return.has(root_parent_id)):
# 					to_return[root_parent_id] += 1
# 				else:
# 					to_return[id] = 0

# 	return to_return


func _count_all_children(instance):
	var count = 0
	for child in instance.get_children():
		count += _count_all_children(child) + 1
	return count


func _get_orphan_list_text(orphan_ids):
	# var consolidated_ids = _consolidate_orphan_children(orphan_ids)
	var text = ""
	for id in orphan_ids:
		var kid_count_text = ''
		var inst = orphanage.orphan_ids[id].instance
		if(is_instance_valid(inst) and inst.get_parent() == null):
			var kid_count = _count_all_children(inst)
			if(kid_count != 0):
				kid_count_text = str(' + ', kid_count)

			var autofree_text = ''
			if(autofree.has_instance_id(id)):
				autofree_text = (" autofreed")

			if(text != ''):
				text += "\n"
			text += str('* ', _strutils.type2str(inst), kid_count_text, autofree_text)

	return text


func orphan_count() -> int:
	return int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT))


func record_orphans(group, subgroup = null):
	return orphanage.process_orphans(group, subgroup)


func convert_instance_ids_to_valid_instances(instance_ids):
	var to_return = []
	for entry in instance_ids:
		if(is_instance_id_valid(entry)):
			to_return.append(instance_from_id(entry))
	return to_return


func end_script(script_path, should_log):
	record_orphans(script_path)
	var orphans = orphanage.get_all_group_orphans(script_path)
	if(orphans.size() > 0 and should_log):
		logger.orphan(str(orphans.size(), ' orphans'))


func end_test(script_path, test_name, should_log = true):
	record_orphans(script_path, test_name)
	orphanage.clean()
	# Must get all the orphans and not just the results of record_orphans
	# because record_orphans may have been called for this group/subgroup
	# already.
	var orphans = get_orphan_ids(script_path, test_name)
	var total_count = orphans.size()
	# orphans = _consolidate_orphan_children(orphans)
	if(orphans.size() > 0 and should_log):
		logger.orphan(str(total_count, ' Orphans'))
		logger.orphan(_strutils.indent_text(_get_orphan_list_text(orphans), 1, '    '))


func get_orphan_ids(group=null, subgroup=null):
	var ids = []
	if(group == null):
		ids = orphanage.orphan_ids.keys()
	elif(subgroup == null):
		ids = orphanage.get_all_group_orphans(group)
	else:
		ids = orphanage.get_orphan_ids(group, subgroup)

	if(hide_autofree):
		for i in range(ids.size() -1, -1, -1):
			if(autofree.has_instance_id(ids[i])):
				ids.remove_at(i)
	return ids


func get_count() -> int:
	return orphan_count()


func log_all():
	var last_script = ''
	var last_test = ''
	var still_orphaned = 0
	# var orphans_by_parent = _consolidate_orphan_children(orphanage.orphan_ids)
	# logger.orphan(_strutils.indent_text(_get_orphan_list_text(orphanage.orphan_ids), 1, '    '))

	for id in orphanage.orphan_ids:
		var entry = orphanage.orphan_ids[id]

		if(last_script != entry.group):
			last_script = entry.group
			last_test = ''
			logger.log(entry.group)

		if(last_test != entry.subgroup):
			logger.inc_indent()
			logger.log(str('- ', entry.subgroup))
			last_test = entry.subgroup
			logger.inc_indent()
			var orphan_ids = orphanage.get_orphan_ids(last_script, last_test)
			logger.orphan(_get_orphan_list_text(orphan_ids))
			logger.dec_indent()
			logger.dec_indent()
	# GutUtils.pretty_print(orphanage.oprhans_by_group)



	# for key in orphanage.orphan_ids:
	# 	var inst = instance_from_id(key)
	# 	if(inst != null and inst is not GutTest and inst.get_parent() == null):
	# 		var entry = orphanage.orphan_ids[key]
	# 		if(entry.group != last_script):
	# 			logger.log(entry.group)
	# 			last_script = entry.group
	# 		if(entry.subgroup != last_test):
	# 			logger.log(str('    - ', entry.subgroup))
	# 			last_test = entry.subgroup

	# 		var kid_count_text = ''
	# 		if(orphans_by_parent.get(key, 0) != 0):
	# 			kid_count_text = str(' + ', orphans_by_parent[inst])
	# 			still_orphaned += orphans_by_parent[inst]
	# 		var autofree_text = ''
	# 		if(autofree.has_instance_id(key)):
	# 			autofree_text = (" autofreed")
	# 		logger.log(str('    ', '    * ', _strutils.type2str(inst), kid_count_text, autofree_text))
	# 		still_orphaned += 1

	# logger.log(str("\nTotal = ", still_orphaned))


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
