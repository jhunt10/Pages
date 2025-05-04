class_name FilterHelper


## Returns true if checking_actor qualifies for at least one filter
static func check_faction_filter(
	source_actor_id:String, 
	source_faction_index:int, 
	faction_filters:Array, 
	checking_actor:BaseActor
)->bool:
	for fact_filter in faction_filters:
		if fact_filter == "Self":
			if source_actor_id == checking_actor.Id:
				return true
		elif fact_filter == "Other":
			if source_actor_id != checking_actor.Id:
				return true
		elif fact_filter == "Ally":
			if (source_faction_index == checking_actor.FactionIndex
				and source_actor_id != checking_actor.Id):
				return true
		elif fact_filter == "Enemy":
			if source_faction_index != checking_actor.FactionIndex:
				return true
	return false
	
