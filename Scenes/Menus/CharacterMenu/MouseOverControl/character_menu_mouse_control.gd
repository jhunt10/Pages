class_name CharacterMenuMouseControl
extends Control

@export var drag_item_icon:TextureRect
@export var speed:float = 5000
@export var offset:Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if self.visible:
		var mouse_pos = get_parent().get_local_mouse_position()
		self.position = self.position.move_toward(mouse_pos - offset, delta * speed)
