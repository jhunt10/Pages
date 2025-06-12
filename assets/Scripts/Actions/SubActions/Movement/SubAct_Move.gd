class_name SubAct_Move
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"RelativePos": BaseSubAction.SubActionPropTypes.MoveValue,
		"MovementType": BaseSubAction.SubActionPropTypes.StringVal
	}
## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_subaction_data:Dictionary)->Array:
	return ["Move"]

func do_thing(parent_action:PageItemAction, subaction_data:Dictionary, metadata:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	var move:MapPos = MapPos.Parse(subaction_data.get("RelativePos", [0,0,0,0]))
	var success = MoveHandler.handle_movement(game_state, actor, move, subaction_data['MovementType'])
	if not success:
		var actor_pos:MapPos = game_state.get_actor_pos(actor)
		actor.on_move_failed.emit(actor_pos)
		return BaseSubAction.Failed
	return BaseSubAction.Success
