class_name InventorySubGroupContainer
extends VBoxContainer

@export var label:Label
@export var inner_container:Container

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_inner_container()->Container:
	return $FlowContainer
