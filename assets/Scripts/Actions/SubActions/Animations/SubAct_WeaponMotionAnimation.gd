class_name SubAct_WeaponMotionAnimation
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"MainHand": BaseSubAction.SubActionPropTypes.BoolVal,
		"OffHand": BaseSubAction.SubActionPropTypes.EnumVal,
		"AnimationSpeed": BaseSubAction.SubActionPropTypes.FloatVal,
	}


func get_prop_enum_values(prop_key:String)->Array:
	if prop_key == "OffHand":
		return [
			"Never",
			"Always",
			"OnlyIfDuel"
		]
	return []


func do_thing(_parent_action:PageItemAction, subaction_data:Dictionary, _metadata:QueExecutionData,
				_game_state:GameStateData, actor:BaseActor)->bool:
	var actor_node:BaseActorNode = CombatRootControl.get_actor_node(actor.Id)
	if !actor_node:
		return BaseSubAction.Success
	
	if not actor_node is ComplexActorNode:
		printerr("SubAct_WeaponMotionAnimation: Non Complex Actor '%s' attempting to use Weapon animation." % [actor.Id])
		return BaseSubAction.Success
	
	var animation_speed = 1.0
	if subaction_data.keys().has("AnimationSpeed"):
		animation_speed = subaction_data.get("AnimationSpeed", 1.0)
	
	# Play Main Hand animation
	if subaction_data.get("MainHand", false):
		actor_node.execute_weapon_motion_animation(animation_speed)
			
	var play_off_hand =  false
	var off_hand_val = subaction_data.get("OffHand", null)
	if !off_hand_val or off_hand_val == "Never":
		play_off_hand = false
	elif  off_hand_val == "Always":
		play_off_hand = true
	elif off_hand_val == "OnlyIfDuel":
		play_off_hand = actor.equipment.get_offhand_weapon() != null
		
	if play_off_hand:
		actor_node.execute_weapon_motion_animation(animation_speed, true)
	
	return BaseSubAction.Success
