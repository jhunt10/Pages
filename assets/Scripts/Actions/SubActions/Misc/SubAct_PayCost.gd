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

func do_thing(parent_action:PageItemAction, _subaction_data:Dictionary, _que_exe_data:QueExecutionData,
				_game_state:GameStateData, actor:BaseActor)->bool:
	if not actor.Que.can_pay_page_ammo(parent_action.ActionKey):
		VfxHelper.create_flash_text(actor, "AMMO", VfxHelper.FlashTextType.NoAmmo)
		return Failed
	actor.Que.try_consume_page_ammo(parent_action.ActionKey)
	return Success
