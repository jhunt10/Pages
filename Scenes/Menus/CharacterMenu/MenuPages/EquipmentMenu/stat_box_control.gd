class_name StatBoxControl
extends Control

@export var stat_labels_container:Container
var _actor:BaseActor
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_actor(actor:BaseActor):
	_actor = actor
	_actor.stats.stats_changed.connect(_sync_stats)
	_sync_stats()

func _sync_stats():
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