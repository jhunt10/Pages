class_name SubAct_DEV_SpawnActor
extends BaseSubAction

func get_required_props()->Dictionary:
	return {
		"TargetKey": BaseSubAction.SubActionPropTypes.TargetKey,
	}
## Returns Tags that are automatically added to the parent Action's Tags
func get_action_tags(_subaction_data:Dictionary)->Array:
	return ["SpawnEffect"]

## Return a of OnQueOptionsData to select the parent action is qued. 
func get_on_que_options(parent_action:PageItemAction, _subaction_data:Dictionary, _actor:BaseActor, _game_state:GameStateData)->Array:
	var options = OnQueOptionsData.new("SelectedActorKey", "Select Effect:", [], [], [])
	
	for actor_key in ActorLibrary.list_all_actor_keys():
		var actor_def = ActorLibrary.get_actor_def(actor_key)
		options.options_vals.append(actor_key)
		options.option_texts.append(actor_def.get("#ObjDetails", {}).get("DisplayName", actor_key))
		var load_path = ActorLibrary.Instance.get_object_def_load_path(actor_key)
		var sprite_name = actor_def.get("#ObjDetails", {}).get("SmallIcon", '')
		options.option_icons.append(SpriteCache.get_sprite(load_path.path_join(sprite_name)))
	var out_list = [options]
	#out_list.append(OnQueOptionsData.new("SelectedDirection", "Select Direction:", ["North", "East", "South", "West"], [], []))
	return out_list

func do_thing(parent_action:PageItemAction, subaction_data:Dictionary, que_exe_data:QueExecutionData,
				game_state:GameStateData, actor:BaseActor)->bool:
	
	var turn_data = que_exe_data.get_current_turn_data()
	var target_key = subaction_data['TargetKey']
	var targets:Array = _find_target_effected_spots(target_key, que_exe_data, game_state, actor)
	
	var actor_key = turn_data.on_que_data['SelectedActorKey']
	var direction = turn_data.on_que_data.get('SelectedDirection', "South")
	var pos:MapPos = targets[0]
	pos.dir = MapPos.Directions.get(direction)
	var new_actor = ActorLibrary.create_actor(actor_key, {}, '')
	if new_actor:
		CombatRootControl.Instance.add_actor(new_actor, pos)
	return BaseSubAction.Success
