class_name ActorLibrary
extends BaseLoadObjectLibrary

## All Libraries should be static, but static override methods can't be called by BaseLoadObjectLibrary.
## So this is the work around.
static var Instance:ActorLibrary

static var _faction_to_actor_key:Dictionary = {}

func get_object_name()->String:
	return 'Actor'
func get_object_key_name()->String:
	return "ActorKey"
func get_def_file_sufixes()->Array:
	return ["_ActorDefs"]
func get_data_file_sufix()->String:
	return "_ActorSave"
func get_object_script_path(object_def:Dictionary)->String:
	return "res://assets/Scripts/Actors/BaseActor.gd"

const _default_corpse_texture_path = "res://assets/Sprites/Actors/DefaultCorpse.png"

func _init() -> void:
	if Instance != null:
		printerr("Multiple ActorLibrarys created.")
		return
	Instance = self
	Instance.init_load()

func reload():
	_faction_to_actor_key.clear()
	super()

func _on_def_loaded(def_key:String, def:Dictionary)->Dictionary:
	var actor_data = def.get("ActorData", {})
	var faction = actor_data.get("Faction", null)
	if faction:
		if not _faction_to_actor_key.has(faction):
			_faction_to_actor_key[faction] = []
		_faction_to_actor_key[faction].append(def_key)
	return def

# Get a static instance of the action
static func get_actor_def(key:String)->Dictionary:
	if !Instance: Instance = ActorLibrary.new()
	return Instance.get_object_def(key)
	
static func has_actor(actor_id:String)->bool:
	if !Instance: Instance = ActorLibrary.new()
	return Instance._loaded_objects.keys().has(actor_id)

static func get_actor(actor_id:String)->BaseActor:
	if !Instance: Instance = ActorLibrary.new()
	var actor = Instance.get_object(actor_id)
	if !actor:
		printerr("ActorLibrary.get_actor: No actor found with id '%s'." % [actor_id])
	return actor

static func get_or_create_actor(key:String, id:String)->BaseActor:
	if !Instance: Instance = ActorLibrary.new()
	if  Instance._loaded_objects.keys().has(id):
		return get_actor(id)
	return create_actor(key, {}, id)

static func create_actor(key:String, data:Dictionary, premade_id:String = '')->BaseActor:
	if !Instance: Instance = ActorLibrary.new()
	if  Instance._loaded_objects.keys().has(premade_id):
		return get_actor(premade_id)
	var actor:BaseActor = Instance.create_object(key, premade_id, data)
	if !actor:
		printerr("ActorLibrary.create_actor: Failed to make actor '%s'." % [key])
		return null
	actor.build_spawned_with_items()
	return actor

static func load_actors(data:Dictionary):
	if !Instance: Instance = ActorLibrary.new()
	Instance._load_objects_saved_data(data)

static func delete_actor(actor:BaseActor):
	if !Instance: Instance = ActorLibrary.new()
	# Deleting the Actor's Items is handled by BaseActor._on_delete()
	Instance.erase_object(actor.Id)
	

static func purge_actors():
	if !Instance: Instance = ActorLibrary.new()
	Instance.purge_objects()

static func list_all_actor_keys()->Array:
	if !Instance: Instance = ActorLibrary.new()
	return Instance._object_defs.keys()

static func list_factions()->Array:
	if !Instance: Instance = ActorLibrary.new()
	return _faction_to_actor_key.keys()
	
static func list_actor_keys_in_faction(faction:String)->Array:
	if !Instance: Instance = ActorLibrary.new()
	return _faction_to_actor_key.get(faction, [])

func get_default_corpse_texture()->Texture2D:
	return load(_default_corpse_texture_path)
