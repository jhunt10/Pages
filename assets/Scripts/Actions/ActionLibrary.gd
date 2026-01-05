class_name ActionLibrary
extends BaseLoadObjectLibrary

const NO_ICON_SPRITE = "res://assets/Sprites/BadSprite.png"

## All Libraries should be static, but static override methods can't be called by BaseLoadObjectLibrary.
## So this is the work around.
static var Instance:ActionLibrary

static var _cached_subaction_scripts:Dictionary = {}

func get_object_name()->String:
	return 'Action'
func get_object_key_name()->String:
	return "ActionKey"
func get_def_file_sufixes()->Array:
	return ["_ActionDefs"]
func get_data_file_sufix()->String:
	return "_ActionDefs"
func is_object_static(_object_def:Dictionary)->bool:
	return true
#func get_object_script_path(object_def:Dictionary)->String:
	#return "res://assets/Scripts/Actions/PageItemAction.gd"

func _init() -> void:
	if Instance != null:
		printerr("Multiple ActionLibrarys created.")
		return
	Instance = self
	#Instance.init_load()

static func list_all_actions()->Array:
	return []
	#if !Instance: Instance = ActionLibrary.new()
	#return Instance._static_objects.values()

static func get_action_def(_key:String)->Dictionary:
	return {}
	#if !Instance: Instance = ActionLibrary.new()
	#return Instance.get_object_def(key)
	
static func get_action(_action_key:String)->PageItemAction:
	return null
	#if !Instance: Instance = ActionLibrary.new()
	#var action = Instance.get_object(action_key)
	#if !action:
		#printerr("ActionLibrary.get_action: No Action found with id '%s'." % [action_key])
	#return action

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
