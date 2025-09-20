extends Control

@export var mouse_over_control:Control
@export var premade_column_label:Control
@export var premade_actor_entry:Control
@export var column_container:Container
@export var entries_container:Container
@export var column_seperator:VSeparator
@export var exit_button:Button

var stats_list = [
"Strength",
"Agility",
"Intelligence",
"Wisdom",
"PPR",
"Mass",
"Speed",
"Awareness",
"HealthMax",
"PhyAttack",
"MagAttack",
"Armor",
"Ward",
"Accuracy",
"Evasion",
"Potency",
"Protection",
"CritChance",
"CritMod",
]

func _ready() -> void:
	for stat_name in stats_list:
		var new_column = premade_column_label.duplicate()
		new_column.set_stat_name(stat_name)
		column_container.add_child(new_column)
		column_container.add_child(column_seperator.duplicate())
	premade_column_label.hide()
	ActorLibrary.get_actor("")
	for actor_key in ActorLibrary.Instance._object_defs.keys():
		var actor = ActorLibrary.get_or_create_actor(actor_key, "ActorLibMenu_"+actor_key)
		var new_entry = premade_actor_entry.duplicate()
		new_entry.set_actor_and_values(actor, stats_list, self)
		entries_container.add_child(new_entry)
	premade_actor_entry.hide()
	exit_button.pressed.connect(queue_free)

func on_mouse_enter_actor_icon(actor_id:String):
	mouse_over_control.show()
	mouse_over_control.label.text = ActorLibrary.get_actor(actor_id).get_display_name()

func on_mouse_enter_stat_label(actor_id, stat_name):
	var actor = ActorLibrary.get_actor(actor_id)
	var stat_mods = actor.stats.get_mod_names_for_stat(stat_name)
	var str_val = stat_name+'\nBase: ' + str(actor.stats.get_base_stat(stat_name)) + "\n"
	for stat_mod in stat_mods:
		str_val += stat_mod + "\n"
	mouse_over_control.label.text = str_val
	mouse_over_control.show()

func on_mouse_leaves():
	mouse_over_control.hide()
