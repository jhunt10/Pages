class_name SubAct_VfxNodeFinish
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		# Type of animation to play
		"VfxKey": BaseSubAction.SubActionPropTypes.StringVal
	}


func get_prop_enum_values(prop_key:String)->Array:
	return []


func do_thing(parent_action:PageItemAction, subaction_data:Dictionary, metadata:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	var actor_node:BaseActorNode = CombatRootControl.get_actor_node(actor.Id)
	if !actor_node:
		return BaseSubAction.Success
	if subaction_data.keys().has("VfxIdKey"):
		var key_id = subaction_data['VfxIdKey']
		var turn_data = metadata.get_current_turn_data()
		var vfx_id = turn_data.data_cache['CreatedVfxs'].get(key_id)
		if vfx_id and actor_node.vfx_holder.has_vfx(vfx_id):
			var vfx = actor_node.vfx_holder.get_vfx(vfx_id)
			vfx.finish()
			
		
	elif subaction_data.keys().has("VfxKey"):
		var vfx_key = subaction_data.get("VfxKey")
		var vfx = actor_node.vfx_holder.get_vfx(vfx_key)
		if vfx:
			vfx.finish()
	return BaseSubAction.Success
