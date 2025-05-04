class_name SubAct_Animation_Ready
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		# Type of animation to play
		"Animation": BaseSubAction.SubActionPropTypes.EnumVal,
		"AnimationSpeed": BaseSubAction.SubActionPropTypes.FloatVal,
	}


func get_prop_enum_values(prop_key:String)->Array:
	if prop_key == "Animation":
		return [
			"Default:Self", # Default for doing something to self or centered on self (ussually Raise or Wiggle)
			"Default:Forward", # Attacking single in the forward direction (ussually Stab)
			"Default:Forward:Arch", # Attacking multiple in the forward direction (ussually Swing)
		]
	return []


func do_thing(parent_action:BaseAction, subaction_data:Dictionary, metadata:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	var actor_node:BaseActorNode = CombatRootControl.get_actor_node(actor.Id)
	if !actor_node:
		return BaseSubAction.Success
	
	var animation_speed = 1.0
	if subaction_data.keys().has("AnimationSpeed"):
		animation_speed = subaction_data.get("AnimationSpeed", 1.0)
	
	var animation_name:String = subaction_data.get('Animation', "")
	if animation_name == "":
		return BaseSubAction.Success
	actor_node.ready_action_animation(animation_name)
	return BaseSubAction.Success

func get_default_weapon_animation(actor:BaseActor, off_hand:bool):
	if off_hand:
		var off_weapon = actor.equipment.get_offhand_weapon()
		if off_weapon:
			return off_weapon.get_load_val("WeaponAnimation", null)
	else:
		var primary_weapon = actor.equipment.get_primary_weapon()
		if primary_weapon:
			return primary_weapon.get_load_val("WeaponAnimation", null)
	return null
	
