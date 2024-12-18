class_name CharacterCard
extends NinePatchRect

@export var button:Button
@export var fade:float:
	set(val):
		fade = val
		var color_val = 0.25 + (fade * 0.75)
		self.modulate = Color(color_val, color_val, color_val)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
