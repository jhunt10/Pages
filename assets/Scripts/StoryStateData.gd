# This class hold the current saveable state of of the entire game, both in and out of combat. 
class_name StoryState

static var Instance:StoryState

func _init() -> void:
	if Instance != null:
		printerr("Multiple StoryState instances created.")
		return
	Instance = self

static var story_id
static var actor_ids:Array = []
static var actors:Array = []
static var items:Array = []
static var effects:Array = []
static var current_player_id 

static func get_player_id()->String:
	if current_player_id:
		return current_player_id
	return ''

static func get_player_actor()->BaseActor:
	if current_player_id:
		return ActorLibrary.get_actor(current_player_id)
	return null

static func start_new_story(starting_class:String):
	if !Instance: Instance = StoryState.new()
	if story_id != null:
		# TODO: Handle existing story
		story_id = null
	story_id = "Story:" + str(ResourceUID.create_id())
	var player_id = "Player_1:" + str(ResourceUID.create_id())
	if starting_class == "Soldier":
		var new_player = ActorLibrary.create_actor("SoldierTemplate", {}, player_id)
		actor_ids.append(new_player.Id)
		current_player_id = new_player.Id
		var sprite = new_player.sprite._build_sprite_sheet()
	PlayerInventory.clear_items()
