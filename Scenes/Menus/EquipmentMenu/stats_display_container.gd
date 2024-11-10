@tool
class_name StatsDisplayContainer
extends BackPatchContainer

@export var name_label:Label
@export var level_label:Label
@export var premade_stat_entry:StatDisplayEntry
@export var entry_container:VBoxContainer

func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
	premade_stat_entry.visible = false

func set_actor(actor:BaseActor):
	name_label.text = actor.details.display_name
	level_label.text = str(actor.stats.level)
	for child in entry_container.get_children():
		if child != premade_stat_entry:
			child.queue_free()
	create_entry("Faction", actor.FactionIndex)
	create_stat_entry("Strength", actor)
	create_stat_entry("Agility", actor)
	create_stat_entry("Intelligence", actor)
	create_stat_entry("Wisdom", actor)

func create_entry(stat_name:String, value):
	var new_entry:StatDisplayEntry = premade_stat_entry.duplicate()
	new_entry.set_values(stat_name, value)
	entry_container.add_child(new_entry)
	new_entry.visible = true

func create_stat_entry(stat_name:String, actor:BaseActor):
	var new_entry:StatDisplayEntry = premade_stat_entry.duplicate()
	var base_value = actor.stats.get_base_stat(stat_name, 0)
	var cur_value = actor.stats.get_stat(stat_name)
	var mods = actor.stats.get_mod_names_for_stat(stat_name)
	new_entry.set_stat(stat_name, base_value, cur_value, mods)
	entry_container.add_child(new_entry)
	new_entry.visible = true
	
