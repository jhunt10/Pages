class_name SubAct_StartAnimation
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"Animation": BaseSubAction.SubActionPropTypes.EnumVal
	}


func get_prop_enum_values(prop_key:String)->Array:
	return ["WalkOut", "WalkIn"]


func do_thing(parent_action:BaseAction, subaction_data:Dictionary, metadata:QueExecutionData,
				game_state:GameStateData, actor:BaseActor):
	var animation = subaction_data['Animation']
	if animation == "WalkOut":
		actor.node.start_walk_out_animation()
	if animation == "WalkIn":
		actor.node.start_walk_in_animation()
