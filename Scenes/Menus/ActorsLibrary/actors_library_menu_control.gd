extends Control

@export var mouse_over_control:Control
@export var premade_column_label:Control
@export var premade_actor_entry:Control
@export var column_container:Container
@export var entries_container:Container
@export var column_seperator:VSeparator
@export var exit_button:Button

var _actors_mapping:Dictionary = {}
var _actors_entries:Dictionary = {}

var _seen_stats_list = []

func _ready() -> void:
	ActorLibrary.get_actor("")
	premade_actor_entry.hide()
	exit_button.pressed.connect(queue_free)
	build_actors()

func build_actors():
	if _actors_mapping.size() > 0:
		return
	for actor_key in ActorLibrary.Instance._object_defs.keys():
		var actor = ActorLibrary.get_or_create_actor(actor_key, "ActorLibMenu_"+actor_key)
		if actor:
			_actors_mapping[actor.Id] = actor
			var _temp = actor.stats.get_stat(StatHelper.HealthMax)
			for stat_name:String in actor.stats._cached_stats.keys():
				if stat_name.begins_with("Resistance:"):
					continue
				
				if stat_name.begins_with(StatHelper.HealthCurrent):
					continue
				if not _seen_stats_list.has(stat_name):
					_seen_stats_list.append(stat_name)
	
	for stat_name in _seen_stats_list:
		var new_column = premade_column_label.duplicate()
		new_column.set_stat_name(stat_name)
		column_container.add_child(new_column)
		var button = new_column.get_node("IconRect/Button")
		button.pressed.connect(_on_stat_button_pressed.bind(stat_name))
		column_container.add_child(column_seperator.duplicate())
	premade_column_label.hide()
	
	
	for actor_id in _actors_mapping.keys():
		var actor = _actors_mapping[actor_id]
		var new_entry = premade_actor_entry.duplicate()
		new_entry.set_actor_and_values(actor, _seen_stats_list, self)
		entries_container.add_child(new_entry)
		_actors_entries[actor_id] = new_entry
		new_entry.show()

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

func _on_stat_button_pressed(stat_name:String):
	print(stat_name)
	for val in _actors_entries.values():
		entries_container.remove_child(val)
	var sort_order = []
	for actor_id in _actors_mapping.keys():
		sort_order.append({
			"ActorId": actor_id,
			"Value": _actors_mapping[actor_id].stats.get_stat(stat_name)
		})
	
	sort_order.sort_custom(sort_stats_descending)
	for data in sort_order:
		var actor_id = data['ActorId']
		var entry = _actors_entries.get(actor_id)
		if entry:
			entries_container.add_child(entry)
	

func sort_stats_descending(a, b):
	if a.get("Value", 0) > b.get("Value", 0):
		return true
	return false
