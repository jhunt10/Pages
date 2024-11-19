class_name SubAct_Move
extends BaseSubAction

const RELATIVE_POS_KEY = "RelativePos"

func get_required_props()->Dictionary:
	return {
		RELATIVE_POS_KEY: BaseSubAction.SubActionPropTypes.MoveValue,
		"MovementType": BaseSubAction.SubActionPropTypes.StringVal,
		"PlayWalkin": BaseSubAction.SubActionPropTypes.BoolVal
	}
## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_subaction_data:Dictionary)->Array:
	return ["Move"]

func do_thing(parent_action:BaseAction, subaction_data:Dictionary, metadata:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	print("Doing Movement")
	#TODO: Movement
	var move:MapPos = MapPos.Parse(subaction_data.get("RelativePos", [0,0,0,0]))
	var success = MoveHandler.handle_movement(game_state, actor, move, subaction_data['MovementType'])
	#if success and subaction_data.get("PlayWalkin", false):
		#actor.node.set_display_pos(game_state.MapState.get_actor_pos(actor), true)
	if not success:
		printerr("MoveFailed")
		actor.node.fail_movement()
		return BaseSubAction.Failed
	return BaseSubAction.Success
