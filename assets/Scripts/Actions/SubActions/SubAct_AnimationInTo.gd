class_name SubAct_AnimationInTo
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"Animation": BaseSubAction.SubActionPropTypes.EnumVal
	}


func get_prop_enum_values(prop_key:String)->Array:
	return [
		"walk/walk_ready", 
		"weapon_raise/raise_ready_main_hand",
		"weapon_swing/swing_ready_main_hand",
		"weapon_stab/stab_ready_main_hand"
	]


func do_thing(parent_action:BaseAction, subaction_data:Dictionary, metadata:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	var animation = subaction_data.get('Animation', null)
	if animation:
		actor.node.into_action_animation(animation)
	return BaseSubAction.Success
