# ------------------------------------------------------------------------------
# This datastructure represents a simple one-to-many relationship.  It manages
# a dictionary of value/array pairs.  It ignores duplicates of both the "one"
# and the "many".  You can disable ignoring dupliates of the "many" via
# ignore_many_dupes.  This setting is not retroactive and will only affect
# new calls to add.
# ------------------------------------------------------------------------------
var items = {}
var ignore_many_dupes = true

# return the size of items or the size of an element in items if "one" was
# specified.
func size(one=null):
	var to_return = 0
	if(one == null):
		to_return = items.size()
	elif(items.has(one)):
		to_return = items[one].size()
	return to_return


# Add an element to "one" if it does not already exist
func add(one, many_item):
	if(items.has(one)):
		if(!ignore_many_dupes or !items[one].has(many_item)):
			items[one].append(many_item)
	else:
		items[one] = [many_item]


func clear():
	items.clear()


func has(one, many_item):
	var to_return = false
	if(items.has(one)):
		to_return = items[one].has(many_item)
	return to_return


func to_s():
	var to_return = ''
	for key in items:
		to_return += str(key, ":  ", items[key], "\n")
	return to_return
