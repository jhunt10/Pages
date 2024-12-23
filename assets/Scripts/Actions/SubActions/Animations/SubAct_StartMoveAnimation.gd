class_name SubAct_StartMovementAnimation
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"RelativePos": BaseSubAction.SubActionPropTypes.MoveValue,
		"MovementType": BaseSubAction.SubActionPropTypes.EnumVal,
		# How many frames it will take to reach target. If null, defaults to reaching target at end of turn.
		"AnimationFrames": BaseSubAction.SubActionPropTypes.IntVal
	}

func get_prop_enum_values(prop_key:String)->Array:
	return [
		"Walk"
	]


func do_thing(parent_action:BaseAction, subaction_data:Dictionary, metadata:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	var move:MapPos = MapPos.Parse(subaction_data.get("RelativePos", [0,0,0,0]))
	var actor_pos = game_state.MapState.get_actor_pos(actor)
	var dest_pos =  MoveHandler.relative_pos_to_real(actor_pos, move)
	
	var actor_node:ActorNode = CombatRootControl.get_actor_node(actor.Id)
	if actor_node:
		var animation_frames = subaction_data.get("AnimationFrames", CombatRootControl.get_remaining_frames_for_turn())
		actor_node.set_move_destination(dest_pos, animation_frames, true)
	return BaseSubAction.Success
