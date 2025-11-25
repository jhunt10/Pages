class_name SubAct_TeleportAnimation
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
	}


func get_prop_enum_values(prop_key:String)->Array:
	return []


func do_thing(parent_action:PageItemAction, subaction_data:Dictionary, metadata:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	var actor_node:BaseActorNode = CombatRootControl.get_actor_node(actor.Id)
	if !actor_node:
		return BaseSubAction.Success
	var actor_pos = game_state.get_actor_pos(actor)
	#var smoke_holder = CombatRootControl.Instance.MapController.create_vfx_holder(actor_pos)
	
	var smoke_vfx = VfxHelper.create_vfx_at_pos(actor_pos, "SmokeVfx", 
	{
		"VfxKey": "Slash_DamageEffect",
		"ScenePath": "res://assets/Scripts/VFXs/ParticalVfxs/smoke_vfx_node.tscn",
		"ShakeActor": false,
		"MatchSourceDir": false
	}, actor)
	smoke_vfx.actor = actor_node
	#if actor_node.visible:
		#actor_node.visible = false
	#else:
		#actor_node.visible = true
	return BaseSubAction.Success
