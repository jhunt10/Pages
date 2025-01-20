# This class hold the current saveable state of of the entire game, both in and out of combat. 
class_name StoryState

static var Instance:StoryState

func _init() -> void:
	if Instance != null:
		printerr("Multiple StoryState instances created.")
		return
	Instance = self

static var story_id
#static var actor_ids:Array = []
#static var actors:Array = []
#static var items:Array = []
#static var effects:Array = []
static var _player_ids:Array = [null, null, null, null]
static var story_flags:Dictionary = {}

#TODO: Curent set up doesn't account for time spent in the save menu
static var total_play_time
static var session_start_unix_time
static var _cached_save_name

static func get_player_index_of_actor(actor:BaseActor)->int:
	for index in range(4):
		if actor.Id == _player_ids[index]:
			return index
	return -1

static func get_player_id(index:int=0):
	if index >= 0 and index < 4:
		var player_id = _player_ids[index]
		if player_id:
			return player_id
	return null

static func get_player_actor(index:int = 0)->BaseActor:
	if index >= 0 and index < 4:
		var player_id = _player_ids[index]
		if player_id:
			return ActorLibrary.get_actor(player_id)
	return null

static func get_player_color(index:int)->Color:
	if index == 0: return Color.BLUE
	elif index == 1: return Color.DARK_GREEN
	elif index == 2: return Color.YELLOW
	elif index == 0: return Color.DARK_RED
	return Color.WHITE

static func start_new_story(starting_class:String):
	if !Instance: Instance = StoryState.new()
	if story_id != null:
		# TODO: Handle existing story
		story_id = null
	story_id = "Story:" + str(ResourceUID.create_id())
	var player_id = "Player_1:" + str(ResourceUID.create_id())
	var new_player = null
	story_flags = {}
	story_flags['StartClass'] = starting_class
	
	if starting_class == "Soldier":
		new_player = ActorLibrary.create_actor("SoldierTemplate", {}, player_id)
	if starting_class == "Mage":
		new_player = ActorLibrary.create_actor("MageTemplate", {}, player_id)
	if starting_class == "Rogue":
		new_player = ActorLibrary.create_actor("RogueTemplate", {}, player_id)
	if starting_class == "Priest":
		new_player = ActorLibrary.create_actor("PriestTemplate", {}, player_id)
	if starting_class == "Tutorial":
		new_player = ActorLibrary.create_actor("TutorialActor", {}, player_id)
		
	if new_player:
		var sprite = new_player.sprite._build_sprite_sheet()
	PlayerInventory.clear_items()
	session_start_unix_time = Time.get_unix_time_from_system()
	total_play_time = 0

static func get_runtime_untix_time()->float:
	if !Instance: return 0
	var val = Instance.total_play_time + (Time.get_unix_time_from_system() - Instance.session_start_unix_time)
	return val

static func build_save_data()->Dictionary:
	var out_data = {}
	out_data['StoryId'] = story_id
	out_data['Actors'] = ActorLibrary.Instance.build_save_data()
	out_data['PlayerInventory'] = PlayerInventory.build_save_data()
	#out_data['Items'] = ItemLibrary.Instance.build_save_data()
	out_data['RunTime'] = total_play_time + (Time.get_unix_time_from_system() - session_start_unix_time)
	out_data['StoryFlags'] = story_flags.duplicate(true)
	return out_data

static func load_save_data(data:Dictionary):
	if !Instance: Instance = StoryState.new()
	story_id = data['StoryId']
	story_flags = data.get("StoryFlags", {}).duplicate(true)
	EffectLibrary.purge_effects()
	#ItemLibrary.load_items(data.get("Items", {}))
	var actors_data = data.get("Actors", {})
	ActorLibrary.load_actors(actors_data)
	
	for actor_id:String in actors_data.keys():
		if actor_id.begins_with("Player_"):
			if actor_id.begins_with("Player_1:"):
				_player_ids[0] = actor_id
			if actor_id.begins_with("Player_2:"):
				_player_ids[1] = actor_id
			if actor_id.begins_with("Player_3:"):
				_player_ids[2] = actor_id
			if actor_id.begins_with("Player_4:"):
				_player_ids[3] = actor_id
	
	var inv_data = data['PlayerInventory']
	if inv_data is Array:
		for item_id in inv_data:
			var item = ItemLibrary.get_item(item_id)
			if item:
				PlayerInventory.add_item(item)
			else:
				printerr("StoryStateData.load_save_data: Failed to find item with id '%s'." % [item_id])
	elif inv_data is Dictionary:
		for item_id in inv_data.keys():
			var item_data = inv_data[item_id]
			var item_key = item_data.get('ObjectKey')
			var item = ItemLibrary.get_or_create_item(item_id, item_key, item_data)
			if item:
				PlayerInventory.add_item(item, inv_data[item_id].get('StackCount', 1))
			else:
				printerr("StoryStateData.load_save_data: Failed to find item with id '%s'." % [item_id])
		
	total_play_time = data.get("RunTime", 0)
	session_start_unix_time = Time.get_unix_time_from_system()
