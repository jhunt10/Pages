class_name TagHelper

## Returns true if any String value in check_for appears in the tag list.
static func tags_include_any_in_array(check_for:Array, tags:Array)->bool:
	for check in check_for:
		if tags.has(check):
			return true
	return false

## Returns true if all String values in check_for appears in the tag list.
static func tags_include_all_in_array(check_for:Array, tags:Array)->bool:
	var is_valid = true
	for check in check_for:
		if not tags.has(check):
			is_valid = false
			break
	return is_valid

static func filters_accept_tags(tag_filter:Dictionary, tags:Array)->bool:
	if tag_filter.get("RequireAllTags", []).size() > 0:
		var require_tags = tag_filter.get('RequireAllTags')
		if not tags_include_all_in_array(require_tags, tags):
			return false
	if tag_filter.get("RequireAnyTags", []).size() > 0:
		var require_tags = tag_filter.get('RequireAnyTags')
		if not tags_include_any_in_array(require_tags, tags):
			return false
	if tag_filter.get("ExcludeAllTags", []).size() > 0:
		var exclude_tags = tag_filter.get('ExcludeAllTags')
		if tags_include_all_in_array(exclude_tags, tags):
			return false
	if tag_filter.get("ExcludeAnyTags", []).size() > 0:
		var exclude_tags = tag_filter.get('ExcludeAnyTags')
		if tags_include_any_in_array(exclude_tags, tags):
			return false
	return true

static func check_tag_filters(propname:String, condition_data:Dictionary, object:BaseLoadObject)->bool:
	var req_all_filters = condition_data.get(propname+"ReqAll", false)
	var filters = condition_data.get(propname, [])
	if not object:
		printerr("TagHelper.check_tag_filters: Null Object provided")
		return false
	if filters.size() == 0:
		return true
	var obj_tags = object.get_tags()
	for filter:Dictionary in filters:
		var is_match = filters_accept_tags(filter, obj_tags)
		if is_match: # Filter accepts Object
			if not req_all_filters: # Only needed one filter
				return true # We're done
		
		else: # Filter does NOT accept obect
			if req_all_filters: # Needed every filter
				return false # We're done
	
	if req_all_filters: # We got here with no failuers
		return true
	else: # We got here with no successes
		return false
	
## Returns true if checking_actor qualifies for at least one filter
static func check_faction_filter(
	source_actor_id:String, 
	source_faction_index:int, 
	faction_filters:Array, 
	checking_actor
)->bool:
	if faction_filters.size() == 0:
		return true
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
	
