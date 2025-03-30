class_name AuraHolder
extends Node2D

var _actor:BaseActor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_aura(zone_node:ZoneNode):
	self.add_child(zone_node)
