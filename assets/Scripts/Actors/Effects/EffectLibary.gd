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

static func create_effect(source, key:String, actor:BaseActor, data:Dictionary, force_id:String='')->BaseEffect:
	if not EffectHelper.is_creating_effect:
		printerr("\n\nDepreciated: Effect created outside of EffectHelper!\n\n")
	print("Creating Effect: %s on actor %s" %[key, actor.Id])
	var effect_data = data
	if not effect_data.get("BeenMerged", false):
		var effect_def = get_effect_def(key)
		effect_data = _merge_defs(data, effect_def)
	
	if effect_data.get("CanStack", false):
		var existing_effects = actor.effects.get_effects_with_key(key)
		if existing_effects.size() > 0:
			var existing_effect:BaseEffect = existing_effects[0]
			existing_effect.merge_new_duplicate_effect_data(source, effect_data)
			return existing_effect
	
	effect_data['EffectedActorId'] = actor.Id
	if source is BaseActor:
		effect_data['SourceId'] = (source as BaseActor).Id
		effect_data['SourceType'] = 'Actor'
	elif source is BasePageItem:
		effect_data['SourceId'] = (source as BasePageItem).Id
		effect_data['SourceType'] = 'Page'
	elif source is BaseEffect:
		effect_data['SourceId'] = (source as BaseEffect).Id
		effect_data['SourceType'] = 'Effect'
	elif source is BaseZone:
		effect_data['SourceId'] = (source as BaseZone).Id
		effect_data['SourceType'] = 'Zone'
	else:
		printerr("EffectLibrary.create_effect: Unknown source type: %s" % [source])
		return null
	# Make Id Unique to actor
	if force_id == '': force_id = key + str(ResourceUID.create_id())
	var effect_id = force_id + ":" + actor.Id
	var effect:BaseEffect = Instance.create_object(key, effect_id, effect_data)
	if !effect:
		printerr("EffectLibrary.create_effect: Failed to make effect '%s'." % [key])
		return null
	
	if effect.get_limited_effect_type() != EffectHelper.LimitedEffectTypes.None:
		if source is BaseActor:
			source.effects.host_limited_effect(effect)
	
	return effect

static func list_effect_defs()->Array:
	if !Instance: Instance = EffectLibrary.new()
	return Instance._object_defs.values()

static func list_all_effects_keys()->Array:
	if !Instance: Instance = EffectLibrary.new()
	return Instance._object_defs.keys()

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
