class_name BaseSubAction
extends GDScript

### SubActions do not get global properties

enum SubActionPropType {TargetKey, DamageKey, MoveValue, StringVal, IntVal}

# Returns a Dictionary of {Property Name, Property Type} for what properties this subaction
# 	exspects to find in it's _subaction_data (Mostly for Page Editor)
func get_required_props()->Dictionary:
	return {}

func do_thing(_parent_action:BaseAction, _subaction_data:Dictionary, _metadata:QueExecutionData,
				_game_state:GameStateData, _actor:BaseActor):
	print("BaseSubAction")
	pass
