class_name EquipmentPageControl
extends Control

@export var name_label:Label
@export var level_label:Label
@export var equipment_slots_container:EquipmentDisplayContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func set_actor(actor:BaseActor):
	name_label.text = actor.details.display_name
	level_label.text = str(actor.stats.level)
	equipment_slots_container.set_actor(actor)
