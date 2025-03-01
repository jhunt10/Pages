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

func get_sprite_bounds()->Rect2i:
	var sprite_text = self.texture
	var size = sprite_text.get_size()
	size.x = size.x / self.hframes
	size.y = size.y / self.vframes
	var min_x = size.x
	var max_x = 0
	var min_y = size.y
	var max_y = 0
	var image = texture.get_image()
	for x in range(size.x):
		for y in range(size.y):
			var pixel = image.get_pixel(x, y)
			if pixel.a == 0:
				continue
			min_x = min(x, min_x)
			max_x = max(x, max_x)
			min_y = min(y, min_y)
			max_y = max(y, max_y)
	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)
