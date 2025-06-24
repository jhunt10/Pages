# This class hold the current saveable state of of the entire game, both in and out of combat. 
extends Node

signal money_changed()

var story_id
var save_id
var _party_actor_ids:Array = []
var _story_stage_index:int
var _story_flags:Dictionary = {}

var _money:int = 0

#TODO: Curent set up doesn't account for time spent in the save menu
var _total_play_time
var _session_start_unix_time
#var _cached_save_name

func add_actor_to_party(actor):
	if actor is String:
		var existing_actor = ActorLibrary.get_actor(actor)
		if existing_actor:
			actor = existing_actor
		else:
			var actor_def = ActorLibrary.get_actor_def(actor)
			if actor_def.size() > 0:
				var player_id = "Player_" + str(_party_actor_ids.size()) + ":" + str(ResourceUID.create_id())
				actor = ActorLibrary.create_actor(actor, {}, player_id)
	if actor and actor is BaseActor:
		_party_actor_ids.append(actor.Id)
	else:
		printerr("StoryState.add_actor_to_party: Invalid / Fail to find Actor from: %s" % [actor])

func get_party_index_of_actor(actor)->int:
	if actor is String:
		actor = ActorLibrary.get_actor(actor)
	for index in range(_party_actor_ids.size()):
		if actor.Id == _party_actor_ids[index]:
			return index
	return -1

func get_party_actor_by_index(index:int)->BaseActor:
	if index >= 0 and index < _party_actor_ids.size():
		var actor_id = _party_actor_ids[index]
		return ActorLibrary.get_actor(actor_id)
	return null


func list_party_actors()->Array:
	var out_list = []
	for index in range(_party_actor_ids.size()):
		var player_id = _party_actor_ids[index]
		if player_id:
			out_list.append(ActorLibrary.get_actor(player_id))
	return out_list

func get_player_color(actor)->Color:
	if actor is String:
		actor = ActorLibrary.get_actor(actor)
	
	var title = actor.pages.get_title_page()
	if title:
		return title.get_player_color()
	#if index == 0: return Color.BLUE
	#elif index == 1: return Color.DARK_GREEN
	#elif index == 2: return Color.YELLOW
	#elif index == 0: return Color.DARK_RED
	return Color.WHITE

func start_new_story():
	#if !Instance: Instance = StoryState.new()
	if story_id != null:
		# TODO: Handle existing story
		story_id = null
	save_id = null
	_story_stage_index = 0
	_story_flags.clear()
	_total_play_time = 0
	
	story_id = "Story:" + str(ResourceUID.create_id())
	var player_id = "Player_1:" + str(ResourceUID.create_id())
	var _new_player = ActorLibrary.create_actor("SoldierTemplate", {}, player_id)
	_party_actor_ids = [player_id]
	
	_session_start_unix_time = Time.get_unix_time_from_system()
	_story_stage_index = -1
	#load_next_story_scene()
	MainRootNode.Instance.open_camp_menu()

func load_next_story_scene():
	var next_scene_data = StatcStoryStages.get_stage_data(_story_stage_index + 1)
	if next_scene_data.size() == 0:
		printerr("Story Over")
		MainRootNode.Instance.open_camp_menu()
		return
	_story_stage_index += 1
	var next_map = next_scene_data.get("MapScene", '')
	var next_dialog = next_scene_data.get("DialogScript", '')
	if next_map:
		LoadManager.load_combat(next_map, next_dialog, true)
	else:
		MainRootNode.Instance.open_camp_menu(next_dialog)
	

func get_runtime_untix_time()->float:
	var val = _total_play_time + (Time.get_unix_time_from_system() - _session_start_unix_time)
	return val

func build_save_data()->Dictionary:
	var out_data = {}
	out_data['Money'] = _money
	out_data['StoryId'] = story_id
	out_data['StoryStageIndex'] = _story_stage_index
	out_data['Actors'] = ActorLibrary.Instance.build_save_data()
	out_data['PartyActors'] = _party_actor_ids
	out_data['PlayerInventory'] = PlayerInventory.build_save_data()
	#out_data['Items'] = ItemLibrary.Instance.build_save_data()
	out_data['RunTime'] = _total_play_time + (Time.get_unix_time_from_system() - _session_start_unix_time)
	out_data['StoryFlags'] = _story_flags.duplicate(true)
	return out_data

func load_save_data(data:Dictionary):
	#if !Instance: Instance = StoryState.new()
	story_id = data['StoryId']
	_story_stage_index = data.get('StoryStageIndex', 0)
	_money = data.get("Money", 0)
	_story_flags = data.get("StoryFlags", {}).duplicate(true)
	EffectLibrary.purge_effects()
	ItemLibrary.load_items(data.get("Items", {}))
	
	
	_party_actor_ids = data.get("PartyActors", [])
	var actors_data = data.get("Actors", {})
	ActorLibrary.load_actors(actors_data)
	
	var inv_data = data['PlayerInventory']
	for item_id in inv_data.keys():
		var item_data = inv_data[item_id]
		var item_key = item_data.get('ObjectKey')
		var item = ItemLibrary.get_or_create_item(item_id, item_key, item_data)
		var invalid_reason = ItemLibrary.validate_object(item)
		if invalid_reason != '':
			printerr("StoryStateData.load_save_data: Item with id '%s' is invalid: %s" % [item_id, invalid_reason])
			continue
		if item:
			PlayerInventory.add_item(item, inv_data[item_id].get('StackCount', 1))
		else:
			printerr("StoryStateData.load_save_data: Failed to find item with id '%s'." % [item_id])
		
	_total_play_time = data.get("RunTime", 0)
	_session_start_unix_time = Time.get_unix_time_from_system()

func get_location()->String:
	var data = StatcStoryStages.get_stage_data(_story_stage_index)
	return data.get("Location", "")

func set_story_flag(key:String, val):
	_story_flags[key] = val

func get_story_flag(key:String):
	if _story_flags.keys().has(key):
		return _story_flags[key]
	return null

func get_current_money()->int:
	return _money

func spend_money(cost:int):
	_money = max(0, _money - cost)
	money_changed.emit()

func add_money(val:int):
	_money = max(0, _money + val)
	money_changed.emit()
