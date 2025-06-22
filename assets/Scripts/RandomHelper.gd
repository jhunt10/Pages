class_name RandomHelper

static func roll()->float:
	return randf()

static func roll_for_chance(odds:float)->float:
	var roll = randf()
	print("RanRoll: %s < %s" % [roll, odds])
	return roll <= odds

static func get_random_actor_from_list(actor_list, want_to_be_selected=false)->BaseActor:
	var actors = {}
	var actor_weights = {}
	for actor in actor_list:
		if actor is String:
			actor = ActorLibrary.get_actor(actor)
		if actor and actor is BaseActor:
			actors[actor.Id] = actor
			actor_weights[actor.Id] = 1
	var selected_id = roll_from_set(actor_weights)
	return actors[selected_id]

static func select_random_targets(parent_action:PageItemAction, actor:BaseActor, selection_data:TargetSelectionData, select_count:int, want_to_be_selected:bool=false)->Array:
	var out_array = []
	var options = selection_data.list_potential_targets()
	if options.size() == 0:
		return out_array
	while out_array.size() < select_count and options.size() > 0:
		var roll = randi() % options.size()
		out_array.append(options[roll])
		options.remove_at(roll)
	return out_array
	

static func select_random_target(parent_action:PageItemAction, actor:BaseActor, selection_data:TargetSelectionData, want_to_be_selected:bool=false):
	var out_array = []
	var options = selection_data.list_potential_targets()
	if options.size() == 0:
		return null#out_array
	#while out_array.size() < select_count and options.size() > 0:
	var roll = randi() % options.size()
		#out_array.append(options[roll])
		#options.remove_at(roll)
	return options[roll]

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
