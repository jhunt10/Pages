class_name StatsPageControl
extends Control

@export var premade_stat_entry:StatEntryContainer
@export var entry_container:Container
@export var scroll_bar:CustScrollBar

var _actor:BaseActor

func set_actor(actor:BaseActor):
	_actor = actor
	_actor.stats.stats_changed.connect(_build_stats)
	_build_stats()

func _build_stats():
	premade_stat_entry.hide()
	for child in entry_container.get_children():
		if child != premade_stat_entry:
			child.queue_free()
	for stat_name in _actor.stats._cached_stats.keys():
		var new_entry:StatEntryContainer = premade_stat_entry.duplicate()
		new_entry.set_stat(_actor, stat_name)
		new_entry.show()
		entry_container.add_child(new_entry)
	scroll_bar.calc_bar_size()
