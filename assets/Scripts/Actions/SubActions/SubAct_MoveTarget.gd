class_name SubAct_MoveTarget
extends BaseSubAction

const RELATIVE_POS_KEY = "RelativePos"

func get_required_props()->Dictionary:
	return {
		RELATIVE_POS_KEY: BaseSubAction.SubActionPropTypes.MoveValue,
		"MovementType": BaseSubAction.SubActionPropTypes.StringVal,
		"TargetKey": BaseSubAction.SubActionPropTypes.StringVal,
		"UseTargetsDirection": BaseSubAction.SubActionPropTypes.BoolVal,
	}
## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_subaction_data:Dictionary)->Array:
	return ["Move"]

func do_thing(parent_action:BaseAction, subaction_data:Dictionary, que_exe_data:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	
	var turn_data = que_exe_data.get_current_turn_data()
	var target_key = subaction_data['TargetKey']
	var target_actors:Array = _find_target_effected_actors(parent_action, subaction_data, target_key, que_exe_data, game_state, actor)
	
	var move:MapPos = MapPos.Parse(subaction_data.get("RelativePos", [0,0,0,0]))
	
	for target in target_actors:
		var apply_move = MapPos.new(move.x, move.y, move.z, move.dir)
		if not subaction_data.get("UseTargetsDirection", true):
			var actor_pos = game_state.get_actor_pos(actor)
			var target_pos = game_state.get_actor_pos(target)
			var rot_diff = (actor_pos.dir - target_pos.dir + 4) % 4
			var point = MapHelper.rotate_relative_pos(apply_move,rot_diff)
			apply_move.x = point.x
			apply_move.y = point.y
		var success = MoveHandler.handle_movement(game_state, target, apply_move, subaction_data['MovementType'])
		if success:
			print("---Target Moved")
		else:
			print("---- Target NOT Moved")
	return BaseSubAction.Success
