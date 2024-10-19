class_name BaseSubAction
extends GDScript

### SubActions do not get global properties

enum SubActionPropType {TargetKey, DamageKey, EffectKey, MissileKey, MoveValue, StringVal, IntVal}

# Returns a Dictionary of {Property Name, Property Type} for what properties this subaction
# 	exspects to find in it's _subaction_data (Mostly for Page Editor)
func get_required_props()->Dictionary:
	return {}

## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_subaction_data:Dictionary)->Array:
	return []

func do_thing(_parent_action:BaseAction, _subaction_data:Dictionary, _metadata:QueExecutionData,
				_game_state:GameStateData, _actor:BaseActor):
	print("BaseSubAction")
	pass

func find_targeted_actors(parent_action:BaseAction, target_key:String, metadata:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->Array:
	var target_params:TargetParameters = parent_action.TargetParams.get(target_key, null)
	if not target_params:
		printerr("BaseSubAction.find_targeted_actors: Failed to find target params with key: '%s' on action '%s'." % [target_key, parent_action.ActionKey])
		return []
		
	if target_params.target_type == TargetParameters.TargetTypes.Self:
		return [actor]
	
	var turn_data = metadata.get_current_turn_data()
	var target = turn_data.targets.get(target_key, null)
	if not target:
		print("No target with key '" + target_key + "' found.")
		return []
	
	var actor_pos = game_state.MapState.get_actor_pos(actor)
	var center_spot = null
	var out_list = []
	
	# Targeting an actor
	if target_params.is_actor_target_type():
		if target is not String:
			printerr("BaseSubAction.find_targeted_actors: Invalid target '%s' provided to Actor Target Type for action '%s'." % [target, parent_action])
		var target_actor:BaseActor = game_state.get_actor(target)
		if not target_actor:
			printerr("BaseSubAction.find_targeted_actors: Failed to find target action '%s' for action '%s'." % [target, parent_action])
		if target_params.is_valid_target_actor(actor, target_actor, game_state):
			center_spot = game_state.MapState.get_actor_pos(target_actor)
			out_list.append(target_actor)
	
	# Targeting a spot
	if target_params.is_spot_target_type():
		if target is not Vector2i:
			printerr("BaseSubAction.find_targeted_actors: Invalid target '%s' provided to Spot Target Type for action '%s'." % [target, parent_action])
		center_spot = MapPos.Vector2i(target)
		for target_actor in game_state.MapState.get_actors_at_pos(center_spot):
			if target_params.is_valid_target_actor(actor, target_actor, game_state):
				out_list.append(target_actor)
	
	# Area of effect
	if center_spot and target_params.has_area_of_effect():
		(center_spot as MapPos).dir = actor_pos.dir
		var area = target_params.get_area_of_effect(center_spot)
		for spot in area:
			for target_actor in game_state.MapState.get_actors_at_pos(spot):
				if target_params.is_valid_target_actor(actor, target_actor, game_state):
					out_list.append(target_actor)
	return out_list
