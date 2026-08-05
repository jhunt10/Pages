class_name SubAct_CheckTeleportDest
extends BaseSubAction

## Check if destination is open and failes action if not
## Needed to check if teleport target is valid before paying cost and starting animation

func get_required_props()->Dictionary:
	return {
		"DestRelativePos": BaseSubAction.SubActionPropTypes.MoveValue,
		"TargetDestKey": BaseSubAction.SubActionPropTypes.TargetKey,
		"TargetActorKey": BaseSubAction.SubActionPropTypes.TargetKey,
	}
## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_parent_action:PageItemAction, _subaction_data:Dictionary)->Array:
	return []

func do_thing(parent_action:PageItemAction, subaction_data:Dictionary, que_exe_data,
				game_state:GameStateData, actor:BaseActor)->bool:
	
	var teleporting_actor:BaseActor = actor
	var move_to_pos:MapPos = null
	
	var turn_data = que_exe_data.get_current_turn_data()
	# This teleport has a selected target destination
	if subaction_data.has("TargetDestKey"):
		var target_dest_key = subaction_data['TargetDestKey']
		var target_dest = turn_data.get_targets(target_dest_key)[0]
		var target_dest_params = _get_target_parameters_for_target_key(target_dest_key, parent_action, actor, turn_data)
		
		
		if subaction_data.get('TargetActorKey', '') != '' and subaction_data['TargetActorKey'] != 'Self':
			var target_actor_key = subaction_data['TargetActorKey']
			var teleporting_target_id = turn_data.get_targets(target_actor_key)[0]
			if teleporting_target_id is String:
				teleporting_actor = game_state.get_actor(teleporting_target_id)
			else:
				print("Invalid Target for teleporting: %s." % [teleporting_target_id])
				return BaseSubAction.Failed
		var target_pos:MapPos = null
		if target_dest_params.is_actor_target_type():
			var target_actor = game_state.get_actor(target_dest)
			target_pos = game_state.get_actor_pos(target_actor)
		if target_dest_params.is_spot_target_type():
			target_pos = target_dest
	
		var relative_pos = MapPos.Parse(subaction_data.get("DestRelativePos", [0,0,0,0])) 
		move_to_pos = target_pos.apply_relative_pos(relative_pos)
	else: # Basic movement
		var relative_pos = MapPos.Parse(subaction_data.get("RelativePos", [0,0,0,0])) 
		move_to_pos = game_state.get_actor_pos(actor).apply_relative_pos(relative_pos)
	
	if not MoveHandler.spot_is_valid_and_open(game_state, move_to_pos):
		VfxHelper.create_flash_text(teleporting_actor, "Failed", BaseFlashTextVfxNode.FlashTextType.FailMessage)
		return BaseSubAction.Failed
	 
	return BaseSubAction.Success
