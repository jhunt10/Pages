class_name SubAct_SpawnBeamNode
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"TargetParamKey": BaseSubAction.SubActionPropTypes.TargetParamKey,
		"TargetKey": BaseSubAction.SubActionPropTypes.TargetKey,
		"DamageKey": BaseSubAction.SubActionPropTypes.DamageKey,
		"MissileKey": BaseSubAction.SubActionPropTypes.MissileKey
	}
## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_subaction_data:Dictionary)->Array:
	return ["SpawnMissile"]


func do_thing(parent_action:BaseAction, subaction_data:Dictionary, que_exe_data:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	var target_params = _get_target_parameters(parent_action, actor, subaction_data)
	var damage_data = parent_action.get_damage_data(actor, subaction_data)
	
	var tag_chain = SourceTagChain.new()\
			.append_source(SourceTagChain.SourceTypes.Actor, actor)\
			.append_source(SourceTagChain.SourceTypes.Action, parent_action)
	var attack_details = parent_action.get_load_val("AttackDetails", {})
	
	var actor_node = CombatRootControl.get_actor_node(actor.Id)
	var script_path = "res://data/VFXs/WaterJet/WaterJet_VfxNode.tscn"
	var new_node:WaterJetVfxNode =  load(script_path).instantiate()
	if not new_node:
		printerr("SubAct_SpawnBeamNode: Failed to load scene: %s" % [script_path])
		return BaseSubAction.Failed
	actor_node.vfx_holder.add_child(new_node)
	
	var beam_data = {
		'AttackDetails': attack_details,
		'DamageData': damage_data,
		'EffectData': parent_action.get_load_val("EffectDatas", []), 
	}
	new_node.set_data(actor_node.vfx_holder, beam_data, target_params)
	
	CombatRootControl.Instance.QueController.end_of_frame.connect(new_node.on_frame_end)
	if actor_node.facing_dir == MapPos.Directions.East:
		new_node.rotation_degrees = 90
	elif actor_node.facing_dir == MapPos.Directions.South:
		new_node.rotation_degrees = 180
	elif actor_node.facing_dir == MapPos.Directions.West:
		new_node.rotation_degrees = 270
	return BaseSubAction.Success
