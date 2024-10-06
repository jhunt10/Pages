class_name SubAct_Move
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"RelativePos": BaseSubAction.SubActionPropType.MoveValue,
		"MovementType": BaseSubAction.SubActionPropType.StringVal
	}

func do_thing(parent_action:BaseAction, subaction_data:Dictionary, metadata:QueExecutionData,
				game_state:GameStateData, actor:BaseActor):
	#TODO: Movement
	var move:MapPos = MapPos.Array(subaction_data.get("RelativePos", [0,0,0,0]))
	var success = MoveHandler.handle_movement(game_state, actor, move, subaction_data['MovementType'])
	pass
