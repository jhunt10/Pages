class_name FullStatDisplayControl
extends Control

@export var entries_container:VBoxContainer
@export var premade_entry:HBoxContainer

var _actor:BaseActor
var entries:Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	premade_entry.hide()
	pass # Replace with function body.


func set_actor(actor:BaseActor):
	if _actor and _actor != actor:
		_actor.stats_changed.disconnect(_sync)
	_actor = actor
	_actor.stats_changed.connect(_sync)
	_sync()

func _sync():
	for child in entries_container.get_children():
		if child != premade_entry:
			child.queue_free()
	var ordered_stats = [
		StatHelper.Level,
		StatHelper.Experience,
		StatHelper.Strength,
		StatHelper.Agility,
		StatHelper.Intelligence,
		StatHelper.Wisdom,
		StatHelper.PhyAttack,
		StatHelper.Armor,
		StatHelper.MagAttack,
		StatHelper.Ward,
		StatHelper.Mass,
		StatHelper.Speed,
		StatHelper.Evasion,
		StatHelper.Accuracy,
		StatHelper.Potency,
		StatHelper.Protection
		]
	for stat_name in _actor.stats._cached_stats.keys():
		if not ordered_stats.has(stat_name):
			ordered_stats.append(stat_name)
	
	for stat_name in ordered_stats:
		var new_entry = premade_entry.duplicate()
		var name_label:Label = new_entry.get_child(0)
		name_label.text = stat_name
		var next_child = new_entry.get_child(1)
		if next_child is Label:
			next_child.text = str(_actor.stats._base_stats.get(stat_name, ''))
			next_child = new_entry.get_child(2)
		if next_child is StatLabelContainer:
			next_child.stat_name = stat_name
			next_child.set_values(stat_name, _actor)
		entries_container.add_child(new_entry)
		entries[stat_name] = new_entry
		new_entry.show()
	pass
