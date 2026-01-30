class_name SubAct_VfxNodeCreate
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		# Type of animation to play
		"VfxKey": BaseSubAction.SubActionPropTypes.StringVal,
		"VfxData": BaseSubAction.SubActionPropTypes.DictVal
	}


func get_prop_enum_values(prop_key:String)->Array:
	return []


func do_thing(parent_action:PageItemAction, subaction_data:Dictionary, metadata:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	var actor_node:BaseActorNode = CombatRootControl.get_actor_node(actor.Id)
	if !actor_node:
		return BaseSubAction.Success
	var vfx_key = subaction_data.get("VfxKey")
	var vfx_data = subaction_data.get("VfxData", {})
	var vfx = VfxHelper.create_vfx_on_actor(actor, vfx_key, vfx_data)
	if subaction_data.keys().has("SaveIdAs"):
		var vfx_id_key = subaction_data['SaveIdAs']
		var turn_data = metadata.get_current_turn_data()
		if not turn_data.data_cache.keys().has("CreatedVfxs"):
			turn_data.data_cache['CreatedVfxs'] = {}
		turn_data.data_cache['CreatedVfxs'][vfx_id_key] = vfx.id
	return BaseSubAction.Success
