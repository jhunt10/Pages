class_name BaseSubAction
extends GDScript

### SubActions do not get global properties

enum SubActionPropTypes {TargetParamKey, SetTargetKey, TargetKey, DamageKey, EffectKey, MissileKey, MoveValue, StringVal, IntVal, EnumVal}

# Returns a Dictionary of {Property Name, Property Type} for what properties this subaction
# 	exspects to find in it's _subaction_data (Mostly for Page Editor)
func get_required_props()->Dictionary:
	return {}

func get_prop_enum_values(prop_key:String)->Array:
	return []

## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_subaction_data:Dictionary)->Array:
	return []

## Return a of OnQueOptionsData to select the parent action is qued. 
func get_on_que_options(parent_action:BaseAction, _subaction_data:Dictionary, _actor:BaseActor, _game_state:GameStateData)->Array:
	#var example = OnQueOptionsData.new("SelectedItemId", "Select Item to use:", _actor.items._items.keys())
	return []

func do_thing(_parent_action:BaseAction, _subaction_data:Dictionary, _metadata:QueExecutionData,
				_game_state:GameStateData, _actor:BaseActor):
	printerr("BaseSubAction.do_thing: No Override.")
	pass

func _get_target_parameters(parent_action:BaseAction, actor:BaseActor, subaction_data:Dictionary)->TargetParameters:
	var target_param_key = subaction_data.get("TargetParamKey", null)
	if !target_param_key or target_param_key == '':
		printerr("BaseSubAction._get_target_parameters: No TargetParamKey found in subaction_data.")
		return null
	var target_parms = TargetingHelper.get_target_params(target_param_key, actor, parent_action)
	if !target_parms:
		printerr("BaseSubAction._get_target_parameters: No TargetParam found in subaction_data.")
		return null
	return target_parms


## Get actors that were effected by the selected target key
func _find_target_effected_actors(parent_action:BaseAction, subaction_data:Dictionary, target_key:String, 
					metadata:QueExecutionData, 	game_state:GameStateData, source_actor:BaseActor)->Array:
	var turn_data = metadata.get_current_turn_data()
	var target_param_key = turn_data.get_param_key_for_target(target_key)
	if !target_param_key or target_param_key == '':
		printerr("BaseSubAction._find_target_effected_actors: No TargetParamKey found in turn_data.")
		return []
	var target_params = TargetingHelper.get_target_params(target_param_key, source_actor, parent_action)
	if !target_params:
		printerr("BaseSubAction._find_target_effected_actors: No TargetParam found with key '%s' from TargetingHelper." % [target_param_key])
		return []
	
	# Shortcut self targeting
	if target_params.target_type == TargetParameters.TargetTypes.Self:
		return [source_actor]
	
	var target = turn_data.get_target(target_key)
	if not target:
		print("No target with key '%s found." % [target_key])
		return []
	
	var source_actor_pos = game_state.MapState.get_actor_pos(source_actor)
	var center_spot:MapPos = null
	var out_list = []
	
	# Targeting an actor
	if target_params.is_actor_target_type():
		if target is not String:
			printerr("BaseSubAction.find_targeted_actors: Invalid target '%s' provided to Actor Target Type for action '%s'." % [target, parent_action])
		var target_actor:BaseActor = game_state.get_actor(target)
		if not target_actor:
			printerr("BaseSubAction.find_targeted_actors: Failed to find target action '%s' for action '%s'." % [target, parent_action])
		if target_params.is_valid_target_actor(source_actor, target_actor, game_state):
			center_spot = game_state.MapState.get_actor_pos(target_actor)
			out_list.append(target_actor)
	
	# Targeting a spot
	if target_params.is_spot_target_type():
		if target is not Vector2i:
			printerr("BaseSubAction.find_targeted_actors: Invalid target '%s' provided to Spot Target Type for action '%s'." % [target, parent_action])
		center_spot = MapPos.Vector2i(target)
		for target_actor in game_state.MapState.get_actors_at_pos(center_spot):
			if target_params.is_valid_target_actor(source_actor, target_actor, game_state) and not out_list.has(target_actor):
				out_list.append(target_actor)
	
	# Area of effect
	if center_spot and target_params.has_area_of_effect():
		center_spot.dir = source_actor_pos.dir
		var area = target_params.get_area_of_effect(center_spot)
		for spot in area:
			for target_actor in game_state.MapState.get_actors_at_pos(spot):
				if target_params.is_valid_target_actor(source_actor, target_actor, game_state) and not out_list.has(target_actor):
					out_list.append(target_actor)
	return out_list
