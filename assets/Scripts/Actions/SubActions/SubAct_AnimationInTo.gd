class_name SubAct_AnimationInTo
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"Animation": BaseSubAction.SubActionPropTypes.EnumVal
	}


func get_prop_enum_values(prop_key:String)->Array:
	return [
		"WEAPON_DEFAULT",
		"walk", 
		"weapon_raise",
		"weapon_swing",
		"weapon_stab"
	]


func do_thing(parent_action:BaseAction, subaction_data:Dictionary, metadata:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	var animation = subaction_data.get('Animation', null)
	if animation == "WEAPON_DEFAULT":
		var primary_weapon = actor.equipment.get_primary_weapon()
		if primary_weapon:
			animation = primary_weapon.get_load_val("WeaponAnimation", null)
	print("SubAct Animation: " + animation)
	var actor_node = CombatRootControl.Instance.MapController.actor_nodes.get(actor.Id)
	if actor_node and animation:
		if animation == "walk":
			actor_node.start_walk_animation()
		else:
			actor_node.start_weapon_animation(animation)
	return BaseSubAction.Success
