class_name SubAct_UseItem
extends BaseSubAction

func do_thing(parent_action:BaseAction, subaction_data:Dictionary, que_exe_data:QueExecutionData,
				game_state:GameStateData, actor:BaseActor):
	print("Use Item SubAction")
	
	var turn_data:TurnExecutionData = que_exe_data.get_current_turn_data()
	var item_id = turn_data.on_que_data['ItemId']
	var item:BaseItem = actor.items.get_item_by_id(item_id)
	
	item.use_on_actor(actor)
	actor.items.delete_item(item_id)
