class_name SubAct_PayCost
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
	}

func do_thing(parent_action:PageItemAction, subaction_data:Dictionary, que_exe_data:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	if not actor.Que.can_pay_page_ammo(parent_action.ActionKey):
		VfxHelper.create_flash_text(actor, "AMMO", VfxHelper.FlashTextType.NoAmmo)
		return Failed
	actor.Que.try_consume_page_ammo(parent_action.ActionKey)
	return Success
