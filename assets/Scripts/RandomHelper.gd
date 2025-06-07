class_name RandomHelper

static func roll()->float:
	return randf()

# Takes a dictionary of <Key, Weight> and returns a weighted random key
static func roll_from_set(data_set:Dictionary)->String:
	var max_val:int = 0
	for weight in data_set.values():
		max_val += weight
	var roll = randi() % (max_val + 1)
	for key:String in data_set.keys():
		if data_set[key] <= 0:
			continue
		roll -= data_set[key]
		if roll <= 0:
			return key
	return ''
