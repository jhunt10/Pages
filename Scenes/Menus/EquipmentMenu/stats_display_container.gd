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
	create_entry("Strength", actor.stats.get_stat("Strength", 0))
	create_entry("Agility", actor.stats.get_stat("Agility", 0))
	create_entry("Intelligence", actor.stats.get_stat("Intelligence", 0))
	create_entry("Wisdom", actor.stats.get_stat("Wisdom", 0))

func create_entry(stat_name:String, value):
	var new_entry:StatDisplayEntry = premade_stat_entry.duplicate()
	new_entry.set_stat(stat_name, value)
	entry_container.add_child(new_entry)
	new_entry.visible = true
