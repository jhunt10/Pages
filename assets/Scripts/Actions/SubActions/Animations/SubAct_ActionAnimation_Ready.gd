class_name SubAct_ActionAnimation_Ready
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
			"Default",
			"Self",		# Raise
			"Forward",	# Stab
			"Arch",		# Swing
		]
	if prop_key == "OffHand":
		return [
			"Never",
			"Always",
			"OnlyIfDuel"
		]
	return []


func do_thing(_parent_action:PageItemAction, subaction_data:Dictionary, _metadata,
				_game_state:GameStateData, actor:BaseActor)->bool:
	# Get Animation Name
	var animation:String = subaction_data.get('Animation', "")
	if !animation or animation == "":
		return BaseSubAction.Success
	
	# Get Actor Node
	var actor_node:BaseActorNode = CombatRootControl.get_actor_node(actor.Id)
	if !actor_node:
		return BaseSubAction.Success
	# Check that Actor Node is Simple or Complex 
	if not (actor_node is ComplexActorNode or actor_node is SimpleActorNode):
		printerr("SubAct_WeaponMotionAnimation: Non Complex or Simple Actor '%s' attempting to use Weapon animation." % [actor.Id])
		return BaseSubAction.Success
	
	# Get Animation Speed
	var animation_speed = CombatRootControl.get_time_scale()
	if subaction_data.keys().has("AnimationSpeed"):
		animation_speed = animation_speed * subaction_data.get("AnimationSpeed", 1.0)
	
	# Short-Cut Simple Actor Nodes
	if actor_node is SimpleActorNode:
		var animation_name:String = subaction_data.get('Animation', "")
		if animation_name == "":
			return BaseSubAction.Success
		actor_node.ready_action_animation(animation_name, animation_speed)
		return BaseSubAction.Success
	
	# Complex Actor Nodes require animation for both hands
	# Play Main Hand animationmer
	if subaction_data.get("MainHand", true):
		actor_node.ready_action_animation(animation, animation_speed)
	
	# Check if play Off Hand animation
	var play_off_hand =  false
	var off_hand_val = subaction_data.get("OffHand", null)
	match (off_hand_val):
		"Never": play_off_hand = false
		"Always": play_off_hand = true
		"OnlyIfDuel": play_off_hand = actor.equipment.get_offhand_weapon() != null
	
	if play_off_hand:
		actor_node.ready_action_animation(animation, animation_speed, true)
	
	return BaseSubAction.Success
