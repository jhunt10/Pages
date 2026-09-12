class_name SubAct_ActionAnimation_Motion
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


func do_thing(_parent_action:PageItemAction, subaction_data:Dictionary, _metadata,
				_game_state:GameStateData, actor:BaseActor)->bool:
	var actor_node:BaseActorNode = CombatRootControl.get_actor_node(actor.Id)
	if !actor_node:
		return BaseSubAction.Success
	
	if not (actor_node is ComplexActorNode or actor_node is SimpleActorNode):
		printerr("SubAct_WeaponMotionAnimation: Non Complex or Simple Actor '%s' attempting to use Weapon animation." % [actor.Id])
		return BaseSubAction.Success
	
	var animation_speed = CombatRootControl.get_time_scale()
	if subaction_data.keys().has("AnimationSpeed"):
		animation_speed = animation_speed * subaction_data.get("AnimationSpeed", 1.0)
	
	# Short Cut Simple Actor Nodes
	if actor_node is SimpleActorNode:
		actor_node.execute_action_motion_animation(animation_speed)
		return BaseSubAction.Success
	
	# Play Main Hand animation
	if subaction_data.get("MainHand", false):
		actor_node.execute_weapon_motion_animation(animation_speed)
	
	# Check if play Off Hand animation
	var play_off_hand =  false
	var off_hand_val = subaction_data.get("OffHand", null)
	match (off_hand_val):
		"Never": play_off_hand = false
		"Always": play_off_hand = true
		"OnlyIfDuel": play_off_hand = actor.equipment.get_offhand_weapon() != null
	
	if play_off_hand:
		actor_node.execute_weapon_motion_animation(animation_speed, true)
	
	return BaseSubAction.Success
