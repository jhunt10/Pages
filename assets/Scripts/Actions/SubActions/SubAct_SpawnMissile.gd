class_name SubAct_SpawnMissile
extends BaseSubAction

func do_thing(parent_action:BaseAction, subaction_data:Dictionary, metadata:QueExecutionData,
				game_state:GameStateData, actor:BaseActor):
	var actor_pos:MapPos = game_state.MapState.get_actor_pos(actor)
	
	var target_key = subaction_data['TargetKey']
	var turndata = metadata.get_current_turn_data()
	if !turndata.targets.has(target_key):
		print("No target found for : ", target_key)
		return
	var frames_per_time = subaction_data['FramesPerTile']
	
	var missile = BaseMissile.new(actor, parent_action, frames_per_time, target_key, subaction_data)
	CombatRootControl.Instance.create_new_missile_node(missile)
