@tool
class_name MiniBlockDisplay
extends Control

@export var awareness:int = 0:
	set(val):
		if val != awareness:
			awareness = min(3, max(-3, val))
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

func load_range(points:Array):
	var image = Image.create_empty(5,5,  false, Image.FORMAT_RGBA8)
	for p in front_points:
		image.set_pixel(2+p[0], 2+p[1], front_color)
	for p in flank_points:
		image.set_pixel(2+p[0], 2+p[1], flank_color)
	for p in back_points:
		image.set_pixel(2+p[0], 2+p[1], back_color)
	
	if awareness == -3:
		for p in front_points:
			image.set_pixel(2+p[0], 2+p[1], flank_color)
		for p in diagonal_front_points:
			image.set_pixel(2+p[0], 2+p[1], back_color)
		for p in flank_points:
			image.set_pixel(2+p[0], 2+p[1], back_color)
		for p in diagonal_back_points:
			image.set_pixel(2+p[0], 2+p[1], back_color)
	if awareness == -2:
		for p in diagonal_front_points:
			image.set_pixel(2+p[0], 2+p[1], flank_color)
		for p in flank_points:
			image.set_pixel(2+p[0], 2+p[1], back_color)
		for p in diagonal_back_points:
			image.set_pixel(2+p[0], 2+p[1], back_color)
	if awareness == -1:
		for p in diagonal_front_points:
			image.set_pixel(2+p[0], 2+p[1], flank_color)
		for p in diagonal_back_points:
			image.set_pixel(2+p[0], 2+p[1], back_color)
	if awareness == 0:
		for p in diagonal_front_points:
			image.set_pixel(2+p[0], 2+p[1], front_color)
		for p in diagonal_back_points:
			image.set_pixel(2+p[0], 2+p[1], back_color)
	if awareness == 1:
		for p in diagonal_front_points:
			image.set_pixel(2+p[0], 2+p[1], front_color)
		for p in diagonal_back_points:
			image.set_pixel(2+p[0], 2+p[1], flank_color)
	if awareness == 2:
		for p in diagonal_front_points:
			image.set_pixel(2+p[0], 2+p[1], front_color)
		for p in flank_points:
			image.set_pixel(2+p[0], 2+p[1], front_color)
		for p in diagonal_back_points:
			image.set_pixel(2+p[0], 2+p[1], flank_color)
	if awareness == 3:
		for p in diagonal_front_points:
			image.set_pixel(2+p[0], 2+p[1], front_color)
		for p in flank_points:
			image.set_pixel(2+p[0], 2+p[1], front_color)
		for p in diagonal_back_points:
			image.set_pixel(2+p[0], 2+p[1], front_color)
		for p in back_points:
			image.set_pixel(2+p[0], 2+p[1], flank_color)
		
	
	texture_rect.texture = ImageTexture.create_from_image(image)

func load_area_matrix(area:AreaMatrix):
	var points = area.relative_points
	load_range(points)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if update:
		var test_range = [
			[-2,-3],[-1,-3],[0,-3],[1,-3],[2,-3],
			[-2,-2],[-1,-2],[0,-2],[1,-2],[2,-2],
			[-2,-1],[-1,-1],[0,-1],[1,-1],[2,-1],
			[-2,0],[-1,0],[0,0],[1,0],[2,0],
			[-2,1],[-1,1],[0,1],[1,1],[2,1],
			[-2,2],[-1,2],[0,2],[1,2],[2,2],
			[-2,3],[-1,3],[0,3],[1,3],[2,3],
			]
		load_range(test_range)
		update = false
