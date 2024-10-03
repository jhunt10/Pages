class_name SubAct_Move
extends BaseSubAction

func do_thing(parent_action:BaseAction, subaction_data:Dictionary, metadata:QueExecutionData,
				game_state:GameStateData, actor:BaseActor):
	#TODO: Movement
	var move:MapPos = MapPos.Array(subaction_data.get("RelativeMovement", [0,0,0,0]))
	var success = MoveHandler.handle_movement(game_state, actor, move, subaction_data['MovementType'])
	pass
