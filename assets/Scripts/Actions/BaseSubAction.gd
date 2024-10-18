class_name BaseSubAction
extends GDScript

### SubActions do not get global properties

enum SubActionPropType {TargetKey, DamageKey, EffectKey, MissileKey, MoveValue, StringVal, IntVal}

# Returns a Dictionary of {Property Name, Property Type} for what properties this subaction
# 	exspects to find in it's _subaction_data (Mostly for Page Editor)
func get_required_props()->Dictionary:
	return {}

## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_subaction_data:Dictionary)->Array:
	return []

func do_thing(_parent_action:BaseAction, _subaction_data:Dictionary, _metadata:QueExecutionData,
				_game_state:GameStateData, _actor:BaseActor):
	print("BaseSubAction")
	pass

func find_target_actor(target_key:String, metadata:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->BaseActor:
	if target_key == "Self":
		return actor
	var turn_data = metadata.get_current_turn_data()
	if !turn_data.targets.has(target_key):
		print("No target with key '" + target_key + "' found.")
		return null
	var target = turn_data.targets[target_key]
	if target is Vector2i:
		var actors = game_state.MapState.get_actors_at_pos(target)
		if actors.size() == 1:
			return actors[0]
		printerr("0 or 2+ actors found by target")
		return game_state.MapState.get_actor_at_pos(target)
	if target is String:
		return game_state.get_actor(target, true)
	printerr("Unknown target type: " + str(target))
	return null
