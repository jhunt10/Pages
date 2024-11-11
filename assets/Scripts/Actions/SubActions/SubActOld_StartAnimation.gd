class_name SubActOld_StartAnimation
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"Animation": BaseSubAction.SubActionPropTypes.EnumVal
	}


func get_prop_enum_values(prop_key:String)->Array:
	return [
		"walk_out", "walk_in", "
		raise_main_hand", "raise_lower_main_hand", 
		"swing_ready_main_hand", "swing_motion_main_hand",
		"stab_ready_main_hand", "stab_motion_main_hand"
	]


func do_thing(parent_action:BaseAction, subaction_data:Dictionary, metadata:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	var animation = subaction_data.get('Animation', null)
	if animation:
		actor.node.start_animation(animation)
	return BaseSubAction.Success
