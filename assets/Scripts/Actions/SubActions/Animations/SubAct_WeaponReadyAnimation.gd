class_name SubAct_WeaponReadyAnimation
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"Animation": BaseSubAction.SubActionPropTypes.EnumVal,
		"MainHand": BaseSubAction.SubActionPropTypes.BoolVal,
		"OffHand": BaseSubAction.SubActionPropTypes.EnumVal,
		"AnimationSpeed": BaseSubAction.SubActionPropTypes.FloatVal,
	}


func get_prop_enum_values(prop_key:String)->Array:
	if prop_key == "Animation":
		return [
			"WEAPON_DEFAULT",
			"Raise",
			"Stab",
			"Swing"
		]
	if prop_key == "OffHand":
		return [
			"Never",
			"Always",
			"OnlyIfDuel"
		]
	return []


func do_thing(parent_action:BaseAction, subaction_data:Dictionary, metadata:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	var animation:String = subaction_data.get('Animation', "")
	if animation == "":
		return BaseSubAction.Success
	
	var actor_node:ActorNode = CombatRootControl.get_actor_node(actor.Id)
	if !actor_node:
		return BaseSubAction.Success
	
	var animation_speed = 1.0
	if subaction_data.keys().has("AnimationSpeed"):
		animation_speed = subaction_data.get("AnimationSpeed", 1.0)
	
	# Play Main Hand animation
	if subaction_data.get("MainHand", false):
		if animation == "WEAPON_DEFAULT":
			var primary_weapon = actor.equipment.get_primary_weapon()
			if primary_weapon:
				var weapon_animation = primary_weapon.get_load_val("WeaponAnimation", null)
				if weapon_animation:
					actor_node.ready_weapon_animation(weapon_animation, animation_speed)
		else:
			actor_node.ready_weapon_animation(animation, animation_speed)
			
	var play_off_hand =  false
	var off_hand_val = subaction_data.get("OffHand", null)
	if !off_hand_val or off_hand_val == "Never":
		play_off_hand = false
	elif  off_hand_val == "Always":
		play_off_hand = true
	elif off_hand_val == "OnlyIfDuel":
		play_off_hand = actor.equipment.get_offhand_weapon() != null
		
	if play_off_hand:
		if animation == "WEAPON_DEFAULT":
			var off_weapon = actor.equipment.get_offhand_weapon()
			if off_weapon:
				var weapon_animation = off_weapon.get_load_val("WeaponAnimation", null)
				if weapon_animation:
					actor_node.ready_weapon_animation(weapon_animation, animation_speed, true)
		else:
			actor_node.ready_weapon_animation(animation, animation_speed, true)
	
	return BaseSubAction.Success
