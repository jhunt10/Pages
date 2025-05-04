class_name SubAct_Animation_Motion
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"AnimationSpeed": BaseSubAction.SubActionPropTypes.FloatVal,
	}


func get_prop_enum_values(prop_key:String)->Array:
	return []


func do_thing(parent_action:BaseAction, subaction_data:Dictionary, metadata:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	var actor_node:BaseActorNode = CombatRootControl.get_actor_node(actor.Id)
	if !actor_node:
		return BaseSubAction.Success
	
	var animation_speed = 1.0
	if subaction_data.keys().has("AnimationSpeed"):
		animation_speed = subaction_data.get("AnimationSpeed", 1.0)
	actor_node.execute_action_motion_animation(animation_speed)
	return BaseSubAction.Success
