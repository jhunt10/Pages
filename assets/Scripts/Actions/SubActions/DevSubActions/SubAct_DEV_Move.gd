class_name SubAct_DEV_Move
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"TargetKey": BaseSubAction.SubActionPropTypes.TargetKey,
	}
## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_subaction_data:Dictionary)->Array:
	return ["SpawnEffect"]

## Return a of OnQueOptionsData to select the parent action is qued. 
func get_on_que_options(parent_action:BaseAction, _subaction_data:Dictionary, _actor:BaseActor, _game_state:GameStateData)->Array:
	var option = OnQueOptionsData.new("DevMoveDir", "Direction", ["North", "South", "East", "West"],["North", "South", "East", "West"])
	return [option]

func do_thing(parent_action:BaseAction, subaction_data:Dictionary, que_exe_data:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	
	var turn_data = que_exe_data.get_current_turn_data()
	var target_key = subaction_data['TargetKey']
	var targets:Array = _find_target_effected_spots(target_key, que_exe_data, game_state, actor)
	
	var direction = turn_data.on_que_data['DevMoveDir']
	var effect_data = {}
	var target:MapPos = targets[0]
	if direction == "North":
		target.dir = MapPos.Directions.North
	if direction == "East":
		target.dir = MapPos.Directions.East
	if direction == "South":
		target.dir = MapPos.Directions.South
	if direction == "West":
		target.dir = MapPos.Directions.West
	game_state.set_actor_pos(actor, target)
	return BaseSubAction.Success
