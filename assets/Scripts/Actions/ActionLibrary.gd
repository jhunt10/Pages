class_name ActionLibrary
extends BaseLoadObjectLibrary

const NO_ICON_SPRITE = "res://assets/Sprites/BadSprite.png"

## All Libraries should be static, but static override methods can't be called by BaseLoadObjectLibrary.
## So this is the work around.
static var Instance:ActionLibrary

static var _cached_icon_sprites : Dictionary = {}
static var _cached_subaction_scripts:Dictionary = {}

func get_object_name()->String:
	return 'Action'
func get_object_key_name()->String:
	return "ActionKey"
func get_def_file_sufix()->String:
	return "_ActionDefs.json"
func get_data_file_sufix()->String:
	return "_ActionDefs.json"
func is_object_static(object_def:Dictionary)->bool:
	return true
func get_object_script_path(object_def:Dictionary)->String:
	return "res://assets/Scripts/Actions/BaseAction.gd"

func _init() -> void:
	if Instance != null:
		printerr("Multiple ActionLibrarys created.")
		return
	Instance = self
	Instance.init_load()

static func list_all_actions()->Array:
	if !Instance: Instance = ActionLibrary.new()
	return Instance._static_objects.values()

static func get_action_def(key:String)->Dictionary:
	if !Instance: Instance = ActionLibrary.new()
	return Instance.get_object_def(key)
	
static func get_action(action_key:String)->BaseAction:
	if !Instance: Instance = ActionLibrary.new()
	var action = Instance.get_object(action_key)
	if !action:
		printerr("ActionLibrary.get_action: No item found with id '%s'." % [action_key])
	return action

#static func get_action_icon(file_path:String)->Texture2D:
	##return SpriteCache.get_sprite(file_path)
	#if !_cached_icon_sprites.keys().has(file_path):
		#var sprite = load(file_path)
		#if sprite:
			#_cached_icon_sprites[file_path] = sprite
		#elif file_path == NO_ICON_SPRITE:
			#printerr("Failed to find NO_ICON_SPRITE at: %s" % [file_path])
			#_cached_icon_sprites[file_path] = null
		#else:
			#printerr("Failed to find action_icon: %s" % [file_path])
			#_cached_icon_sprites[file_path] = get_action(NO_ICON_SPRITE)
	#return _cached_icon_sprites[file_path]

static func get_sub_action_script(script_path)->BaseSubAction:
	if _cached_subaction_scripts.keys().has(script_path):
		return _cached_subaction_scripts[script_path]
	var script = load(script_path)
	if not script:
		printerr("ActionLibrary.get_sub_action_script: No script found with name '%s'." % [script_path])
		return null
	var sub_action = script.new()
	_cached_subaction_scripts[script_path] = sub_action
	return sub_action
