class_name ActorDetailsEntryContainer
extends BaseObjectDetailsEntryContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	pass

## Load the top level details displayed while entry is minimized
func _load_mini_details():
	super()

func _should_show_add_button()->bool:
	var story_id = StoryState.story_id
	return StoryState.story_id != null and StoryState.story_id != ''
	
func _on_add_pressed():
	if StoryState.story_id:
		if thing_def.has("ActorKey"):
			var key = thing_def.get("ActorKey", "")
			StoryState.add_actor_to_party(key)

## Load full details displayed when entry is exspanded
func _load_full_details():
	super()
	var stats = thing_def.get("Stats", {})
	for stat_name in stats.keys():
		if stat_name == "StartingAttributeLevels":
			continue
		var stat_val = stats[stat_name]
		var new_mod:StatModLabelContainer = premade_stat_mod_label.duplicate()
		new_mod.set_mod_data({
			"StatName":stat_name,
			"ModType": "Add",
			"Value": stat_val
			})
		stat_mods_container.add_child(new_mod)
		new_mod.show()
	
	## Stat Mods
	#var stat_mods = page.get_passive_stat_mods()
	#if page_effect_def:
		#stat_mods = page_effect_def.get("StatMods", {})
	#for mod_data in stat_mods.values():
		#var new_mod:StatModLabelContainer = premade_stat_mod_label.duplicate()
		#new_mod.set_mod_data(mod_data)
		#stat_mods_container.add_child(new_mod)
		#new_mod.show()
	#loaded_details = true
	
