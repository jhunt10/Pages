@tool
class_name ActorBodySprite
extends Sprite2D

@export var direction:int:
	set(val):
		direction = (val +  4) % 4
		if self.vframes == 4:
			if direction == 0: self.frame_coords.y = 1
			if direction == 1: self.frame_coords.y = 2
			if direction == 2: self.frame_coords.y = 0
			if direction == 3: self.frame_coords.y = 3

@export var frame_index:int:
	set(val):
		frame_index = max(0, min(self.hframes-1, val))
		self.frame_coords.x = frame_index

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
