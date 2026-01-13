class_name Roll

static func roll()->float:
	return randf()

static func for_chance(odds:float, _want_low:bool=true)->bool:
	var roll_val = randf()
	return roll_val <= odds

static func for_actor(actor:BaseActor, odds:float, want_low:bool=true)->bool:
	var roll_val = get_roll_for_actor(actor, want_low)
	if want_low:
		return roll_val <= odds
	else:
		return roll_val >= odds

static func get_roll_for_actor(_actor:BaseActor, _want_low:bool=true)->float:
	var roll_val = randf()
	return roll_val

static func random_actor_from_list(actor_list, _want_to_be_selected=false)->BaseActor:
	var actors = {}
	var actor_weights = {}
	for actor in actor_list:
		if actor is String:
			actor = ActorLibrary.get_actor(actor)
		if actor and actor is BaseActor:
			actors[actor.Id] = actor
			actor_weights[actor.Id] = 1
	var selected_id = from_set(actor_weights)
	return actors[selected_id]

static func random_targets(_parent_action:PageItemAction, _actor:BaseActor, selection_data:TargetSelectionData, select_count:int, _want_to_be_selected:bool=false)->Array:
	var out_array = []
	var options = selection_data.list_potential_targets()
	if options.size() == 0:
		return out_array
	while out_array.size() < select_count and options.size() > 0:
		var roll_val = randi() % options.size()
		out_array.append(options[roll_val])
		options.remove_at(roll_val)
	return out_array
	

static func random_target(_parent_action:PageItemAction, _actor:BaseActor, selection_data:TargetSelectionData, _want_to_be_selected:bool=false):
	var options = selection_data.list_potential_targets()
	if options.size() == 0:
		return null#out_array
	#while out_array.size() < select_count and options.size() > 0:
	var roll_val = randi() % options.size()
		#out_array.append(options[roll])
		#options.remove_at(roll)
	return options[roll_val]

# Takes a dictionary of <Key, Weight> and returns a weighted random key
static func from_set(data_set:Dictionary)->String:
	var max_val:int = 0
	for weight in data_set.values():
		max_val += weight
	var roll_val = randi() % (max_val + 1)
	for key:String in data_set.keys():
		if data_set[key] <= 0:
			continue
		roll_val -= data_set[key]
		if roll_val <= 0:
			return key
	return ''
