class_name EffectLibrary
extends BaseLoadObjectLibrary

const NO_ICON_SPRITE = "res://assets/Sprites/BadSprite.png"

## All Libraries should be static, but static override methods can't be called by BaseLoadObjectLibrary.
## So this is the work around.
static var Instance:EffectLibrary

static var _cached_icon_sprites : Dictionary = {}
static var _cached_subeffect_scripts:Dictionary = {}

func get_object_name()->String:
	return 'Effect'
func get_object_key_name()->String:
	return "EffectKey"
func get_def_file_sufix()->String:
	return "_EffectDefs.json"
func get_data_file_sufix()->String:
	return "_EffectsSave.json"
func is_object_static(object_def:Dictionary)->bool:
	return false
func get_object_script_path(object_def:Dictionary)->String:
	return object_def.get("EffectScriptPath", "res://assets/Scripts/Actors/Effects/BaseEffect.gd")

func _init() -> void:
	if Instance != null:
		printerr("Multiple EffectLibrarys created.")
		return
	Instance = self
	Instance.init_load()

func erase_object(object_id:String):
	super(object_id)

static func purge_effects():
	if !Instance: Instance = EffectLibrary.new()
	Instance.purge_objects()

## Should only be called by Effect Helper
static func _create_effect(source, actor:BaseActor, key:String, data:Dictionary, force_id:String='', game_state:GameStateData=null, suppress_signals:bool = false)->BaseEffect:
	if not EffectHelper.is_creating_effect:
		printerr("\n\nDepreciated: Effect created outside of EffectHelper! Use EffectHelper.create_effect instead.\n\n")
	print("Creating Effect: %s on actor %s" %[key, actor.Id])
	
	var effect_data = data.duplicate()
	
	# Check if CanStack
	var merged_effect_data = get_merged_effect_def(key, data)
	if merged_effect_data.get("CanStack", false):
		var existing_effects = actor.effects.get_effects_with_key(key)
		if existing_effects.size() > 0:
			var existing_effect:BaseEffect = existing_effects[0]
			existing_effect.merge_new_duplicate_effect_data(source, merged_effect_data)
			return existing_effect
	
	# Set Source and other run-time data
	effect_data['EffectedActorId'] = actor.Id
	if source is BaseActor:
		effect_data['SourceType'] = 'Actor'
		effect_data['SourceId'] = (source as BaseActor).Id
		effect_data['SourceActorId'] = (source as BaseActor).Id
	elif source is BasePageItem:
		effect_data['SourceType'] = 'Page'
		effect_data['SourceId'] = (source as BasePageItem).Id
		effect_data['SourceActorId'] = actor.Id
	elif source is BaseEffect:
		effect_data['SourceType'] = 'Effect'
		effect_data['SourceId'] = (source as BaseEffect).Id
		var sact = (source as BaseEffect).get_source_actor()
		if sact: effect_data['SourceActorId'] = sact.Id
	elif source is BaseZone:
		effect_data['SourceType'] = 'Zone'
		effect_data['SourceId'] = (source as BaseZone).Id
		var sact = (source as BaseZone).get_source_actor()
		if sact: effect_data['SourceActorId'] = sact.Id
	else:
		printerr("EffectLibrary.create_effect: Unknown source type: %s" % [source])
		return null
	
	# Make Id Unique to actor
	var effect_id = force_id
	if effect_id == '': 
		effect_id = key + str(ResourceUID.create_id())
	if not effect_id.ends_with(":" + actor.Id):
		effect_id += ":" + actor.Id
	
	var effect:BaseEffect = Instance.create_object(key, effect_id, effect_data)
	if !effect:
		printerr("EffectLibrary.create_effect: Failed to make effect '%s'." % [key])
		return null
	# TODO: I'm coming in late and don't know why this isnt in init()
	effect._source = source
	return effect

static func list_effect_defs()->Array:
	if !Instance: Instance = EffectLibrary.new()
	return Instance._object_defs.values()

static func list_all_effects_keys()->Array:
	if !Instance: Instance = EffectLibrary.new()
	return Instance._object_defs.keys()

static func has_effect_key(key:String)->bool:
	if !Instance: Instance = EffectLibrary.new()
	return Instance._object_defs.keys().has(key)
	
static func get_effect_def(key:String)->Dictionary:
	if !Instance: Instance = EffectLibrary.new()
	return Instance.get_object_def(key)

static func get_merged_effect_def(key:String, data:Dictionary)->Dictionary:
	if !Instance: Instance = EffectLibrary.new()
	var effect_def = get_effect_def(key)
	var effect_data = _merge_defs(data, effect_def)
	effect_data['BeenMerged'] = true
	return effect_data
	
static func get_effect(effect_key:String)->BaseEffect:
	var effect = Instance.get_object(effect_key)
	if !effect:
		printerr("EffectLibrary.get_effect: No item found with id '%s'." % [effect_key])
	return effect

static func get_sub_effect_script(script_path)->BaseSubEffect:
	if _cached_subeffect_scripts.keys().has(script_path):
		return _cached_subeffect_scripts[script_path]
	var script = load(script_path)
	if not script:
		printerr("EffectLibrary.get_sub_effect_script: No script found with name '%s'." % [script_path])
		return null
	var sub_effect = script.new()
	_cached_subeffect_scripts[script_path] = sub_effect
	return sub_effect
