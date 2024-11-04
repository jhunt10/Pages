class_name SubAct_Teleport
extends BaseSubAction

const RELATIVE_POS_KEY = "RelativePos"

func get_required_props()->Dictionary:
	return {
		"DestRelativePos": BaseSubAction.SubActionPropTypes.MoveValue,
		"TargetDestKey": BaseSubAction.SubActionPropTypes.TargetKey,
		"TargetActorKey": BaseSubAction.SubActionPropTypes.TargetKey,
	}
## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_subaction_data:Dictionary)->Array:
	return ["Move"]

func do_thing(parent_action:BaseAction, subaction_data:Dictionary, que_exe_data:QueExecutionData,
				game_state:GameStateData, actor:BaseActor):
	
	var turn_data = que_exe_data.get_current_turn_data()
	var target_dest_key = subaction_data['TargetDestKey']
	var target_actor_key = subaction_data['TargetActorKey']
	var target_dest = turn_data.get_target(target_dest_key)
	var target_dest_params = parent_action.get_targeting_params(
				turn_data.get_param_key_for_target(target_dest_key), actor)
	
	var teleporting_target_id = turn_data.get_target(target_actor_key)
	var teleporting_actor:BaseActor = null
	if teleporting_target_id is String:
		teleporting_actor = game_state.get_actor(teleporting_target_id)
	else:
		print("Invalid Target for teleporting: %s." % [teleporting_target_id])
	
	var target_pos:MapPos = null
	if target_dest_params.is_actor_target_type():
		var target_actor = game_state.get_actor(target_dest)
		target_pos = game_state.MapState.get_actor_pos(target_actor)
	if target_dest_params.is_spot_target_type():
		target_pos = target_dest
	
	var relative_pos = MapPos.Parse(subaction_data.get("DestRelativePos", [0,0,0,0])) 
	var move_to_pos:MapPos = target_pos.apply_relative_pos(relative_pos)
	print("Teleporting to target: %s | targeted:%s | relpos:%s" % [move_to_pos, target_pos, relative_pos])
	if MoveHandler.spot_is_valid_and_open(game_state, move_to_pos):
		game_state.MapState.set_actor_pos(teleporting_actor, move_to_pos)
