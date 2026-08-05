class_name SubAct_PayCost
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
	}

## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_parent_action:PageItemAction, _subaction_data:Dictionary)->Array:
	var ammo_data = _parent_action.action_data.get("AmmoData", {})
	var ammo_type = ammo_data.get("AmmoType", "")
	if ammo_type != "":
		return [ammo_type+"Ammo"]
	return []

func do_thing(parent_action:PageItemAction, _subaction_data:Dictionary, _que_exe_data,
				_game_state:GameStateData, actor:BaseActor)->bool:
	if not parent_action.can_pay_ammo_cost():
		VfxHelper.create_flash_text(actor, "AMMO", BaseFlashTextVfxNode.FlashTextType.NoAmmo)
		return Failed
	parent_action.pay_ammo_cost()
	return Success
