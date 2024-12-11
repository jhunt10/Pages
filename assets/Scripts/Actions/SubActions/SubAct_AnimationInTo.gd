class_name SubAct_AnimationInTo
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"Animation": BaseSubAction.SubActionPropTypes.EnumVal
	}


func get_prop_enum_values(prop_key:String)->Array:
	return [
		"WEAPON_DEFAULT",
		"move_walk_forward", 
		"move_walk_back",
		"move_walk_left",
		"move_walk_right",
		"move_turn_left",
		"move_turn_right",
		"weapon_raise",
		"weapon_swing",
		"weapon_stab"
	]


func do_thing(parent_action:BaseAction, subaction_data:Dictionary, metadata:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	var animation:String = subaction_data.get('Animation', "")
	if animation == "":
		return true
	if animation == "WEAPON_DEFAULT":
		var primary_weapon = actor.equipment.get_primary_weapon()
		if primary_weapon:
			animation = primary_weapon.get_load_val("WeaponAnimation", null)
	var animation_speed = 1.0
	if subaction_data.keys().has("AnimationSpeed"):
		animation_speed = subaction_data.get("AnimationSpeed", 1.0)
	print("SubAct Animation: " + animation)
	var actor_node:ActorNode = CombatRootControl.Instance.MapController.actor_nodes.get(actor.Id)
	if actor_node and animation:
		if animation.begins_with("move_"):
			actor_node.start_walk_animation(animation, animation_speed)
		else:
			actor_node.start_weapon_animation(animation, animation_speed)
	return BaseSubAction.Success
