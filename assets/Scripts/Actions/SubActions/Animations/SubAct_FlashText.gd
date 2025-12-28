class_name SubAct_FlashText
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		# Type of animation to play
		"Text": BaseSubAction.SubActionPropTypes.StringVal,
		"Color": BaseSubAction.SubActionPropTypes.MoveValue,
		"FlashTextData": BaseSubAction.SubActionPropTypes.DictVal
	}


func get_prop_enum_values(prop_key:String)->Array:
	if prop_key == "Animation":
		return [
			"Default:Self", # Default for doing something to self or centered on self (ussually Raise or Wiggle)
			"Default:Forward", # Attacking single in the forward direction (ussually Stab)
			"Default:Forward:Arch", # Attacking multiple in the forward direction (ussually Swing)
		]
	return []


func do_thing(parent_action:PageItemAction, subaction_data:Dictionary, metadata:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	var actor_node:BaseActorNode = CombatRootControl.get_actor_node(actor.Id)
	if !actor_node:
		return BaseSubAction.Success
	var flash_text_data = subaction_data.get("FlashTextData", {})
	var color = Color.WHITE
	if subaction_data.has("Color"):
		var color_str = subaction_data.get("Color")
		var color_arr = JSON.parse_string(color_str)
		if color_arr and color_arr is Array and color_arr.size() == 4:
			color = Color(color_arr[0], color_arr[1], color_arr[2], color_arr[3])
		else:
			printerr("SubAct_FlashText: Failed to parse color string: '%s'" % [color_str])
	actor_node.vfx_holder.flash_text_controller.add_flash_text(subaction_data.get("Text", ""), VfxHelper.FlashTextType.Message, flash_text_data, color)
	return BaseSubAction.Success
