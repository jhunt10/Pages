class_name SubAct_Heal
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"TargetKey": BaseSubAction.SubActionPropTypes.TargetKey,
		"Value": BaseSubAction.SubActionPropTypes.IntVal
	}
## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_subaction_data:Dictionary)->Array:
	return ["Heal"]

func do_thing(parent_action:PageItemAction, subaction_data:Dictionary, que_exe_data:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	
	var turn_data = que_exe_data.get_current_turn_data()
	var target_key = subaction_data['TargetKey']
	var targets:Array = _find_target_effected_actors(parent_action, subaction_data, target_key, que_exe_data, game_state, actor)
	var heal_value:float = subaction_data.get("Value", 0)
	for target:BaseActor in targets:
		var max_hp = float(target.stats.max_health)
		var current_hp = target.stats.current_health
		var heal_ammount = min(ceili(max_hp * (heal_value / 100.0)), max_hp - current_hp)
		if heal_ammount > 0:
			target.stats.apply_healing(heal_ammount, false)
			VfxHelper.create_flash_text(target, heal_ammount, VfxHelper.FlashTextType.Healing_Dmg)
		
	return BaseSubAction.Success
