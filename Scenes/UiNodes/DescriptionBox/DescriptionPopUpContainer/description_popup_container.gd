class_name DecscriptionPopUpContainer
extends Control

@export var back_patch:BackPatchContainer
@export var message_box:RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if self.visible:
		self.global_position = self.get_global_mouse_position() - Vector2(0, back_patch.size.y + 8)
	pass
