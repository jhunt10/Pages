class_name BaseSubAction
extends GDScript

### SubActions do not get global properties

func do_thing(_parent_action:BaseAction, _subaction_data:Dictionary, _metadata:QueExecutionData,
				_game_state:GameStateData, _actor:BaseActor):
	print("BaseSubAction")
	pass
