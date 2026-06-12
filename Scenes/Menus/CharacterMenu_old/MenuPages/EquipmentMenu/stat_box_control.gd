class_name StatBoxControl
extends Control

@export var stat_labels_container:Container
var _actor:BaseActor

func set_actor(actor:BaseActor):
	if _actor and _actor != actor:
		_actor.stats_changed.disconnect(_sync_stats)
	if actor != _actor:
		actor.stats_changed.connect(_sync_stats)
	_actor = actor
	_sync_stats()

func _sync_stats():
	if not self.is_visible_in_tree():
		return
	var stat_lables = []
	_get_stat_labels(stat_labels_container, stat_lables)
	for child in stat_lables:
		child.set_stat_values(_actor)

func _get_stat_labels(container, list):
	for child in container.get_children():
		if child is StatLabelContainer:
			list.append(child)
		elif child is Container:
			_get_stat_labels(child, list)
