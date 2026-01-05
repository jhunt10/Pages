@tool
class_name MiniAwarenessDisplay
extends Control

@export var awareness:int:
	set(val):
		awareness = val
		update = true
@export var texture_rect:TextureRect
@export var update:bool = false

const front_color:Color = Color.DARK_GREEN
const flank_color:Color = Color.ORANGE
const back_color:Color = Color.RED

const front_points = [[-1,-2],[0,-2],[1,-2],[0,-1]]
const diagonal_front_points = [[-2,-2],[-1,-1],[1,-1],[2,-2]]
const flank_points = [[-2,-1],[-2,0],[-2,1],[-1,0], [2,-1],[2,0],[2,1],[1,0]]
const diagonal_back_points = [[-2,2],[-1,1],[1,1],[2,2]]
const back_points = [[-1,2],[0,2],[1,2],[0,1]]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !texture_rect:
		texture_rect = $TextureRect
	pass # Replace with function body.

func sync_display():
	var center = MapPos.new(0,0,0,0)
	var image = Image.create_empty(5,5,  false, Image.FORMAT_RGBA8)
	for x in range(-2,3):
		for y in range(-2,3):	
			if x == 0 and y == 0:
				continue
			var pos = MapPos.new(x, y, 0, 0)
			var point = [x+2, y+2]
			var atk_dir = AttackHandler.get_relative_attack_direction(pos, center, awareness)
			match atk_dir:
				AttackHandler.AttackDirection.Front:
					image.set_pixel(point[0], point[1], front_color)
				AttackHandler.AttackDirection.Flank:
					image.set_pixel(point[0], point[1], flank_color)
				AttackHandler.AttackDirection.Back:
					image.set_pixel(point[0], point[1], back_color)
	texture_rect.texture = ImageTexture.create_from_image(image)
	update = false
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if update:
		sync_display()
