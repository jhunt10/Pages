class_name SubAct_PayCost
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
	}

func do_thing(parent_action:BaseAction, subaction_data:Dictionary, que_exe_data:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	if not actor.Que.can_pay_page_ammo(parent_action.ActionKey):
		CombatRootControl.Instance.create_flash_text_on_actor(actor, "AMMO", Color.ORANGE)
		return Failed
	actor.Que.consume_page_ammo(parent_action.ActionKey)
	
	#var cost_data = parent_action.CostData
	#var cant_pay_name = null
	#for bar_name in cost_data.keys():
		#var cost_val = cost_data[bar_name]
		#var cur_val = actor.stats.get_bar_stat(bar_name)
		#if cur_val < cost_val:
			#cant_pay_name = bar_name
			#break
	#if cant_pay_name:
		#CombatRootControl.Instance.create_flash_text_on_actor(actor, cant_pay_name, Color.ORANGE)
		#return Failed
	#
	#for bar_name in cost_data.keys():
		#var cost_val = cost_data[bar_name]
		#actor.stats.reduce_bar_stat_value(bar_name, cost_val)
	
	return Success
