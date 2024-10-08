class_name EffectScriptEditControl
extends Control

static var EFFECT_SCRIPTS_PATH = "res://assets/Scripts/Effects/"


@onready var script_option_button:LoadedOptionButton = $VBoxContainer/HBoxContainer/LoadedOptionButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	script_option_button.get_options_func = get_effect_scripts
	script_option_button.load_options()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_effect_scripts()->Array:
	return get_sub_actions_scripts()

static func rebuild_effect_script_path(name):
	return "Effect_" + name + ".gd"

static func get_sub_actions_scripts():
	var list = []
	if MainRootNode.effect_libary.loaded:
		_search_for_effects(EFFECT_SCRIPTS_PATH, list)
	else:
		printerr("SubActionEntryControl.get_sub_actions_scripts: Actions not loaded")
	return list

static func _search_for_effects(path, list):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file:String = dir.get_next()
		while file != "":
			var full_path = path+file
			if dir.current_is_dir(): _search_for_effects(full_path, list)
			elif file.begins_with("Effect_") and file.ends_with(".gd"): 
				list.append(file.trim_prefix("Effect_").trim_suffix(".gd"))
			file = dir.get_next()
