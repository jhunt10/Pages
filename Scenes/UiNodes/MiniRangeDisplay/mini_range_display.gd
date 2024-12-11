@tool
class_name MiniRangeDisplay
extends Control

@export var texture_rect:TextureRect
@export var update:bool = false

const center_color:Color = Color.BLACK
const range_color:Color = Color.RED

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !texture_rect:
		texture_rect = $TextureRect
	pass # Replace with function body.

func load_range(points:Array):
	var x_points = []
	var y_points = []
	var max_x = 0
	var min_x = 0
	var max_y = 0
	var min_y = 0
	for point in points:
		if point is Vector2i:
			if point.x > max_x: max_x = point.x
			if point.y > max_y: max_y = point.y
			if point.x < min_x: min_x = point.x
			if point.y < min_y: min_y = point.y
			x_points.append(point.x)
			y_points.append(point.y)
		if point is Array:
			if point[0] > max_x: max_x = point[0]
			if point[1] > max_y: max_y = point[1]
			if point[0] < min_x: min_x = point[0]
			if point[1] < min_y: min_y = point[1]
			x_points.append(point[0])
			y_points.append(point[1])
	
	var max_size = max(max_x + 1 - min_x, max_y + 1 - min_y, 5)
	var image_size = Vector2i(max_size, max_size)
	if max_x - min_x > 5 or max_y - min_y > 5:
		image_size = Vector2i(11,11)
	
	var center = Vector2i(floori(float(image_size.x) / 2.0)-(max_x + min_x), floori(float(image_size.y) / 2.0)-((max_y + min_y)/2))
	#print("MinX: %s, MaxX: %s, MinY:%s, MaxY:%s, Center: %s"%[min_x, max_x, min_y, max_y, center])
	
	var image = Image.create_empty(image_size.x, image_size.y,  false, Image.FORMAT_RGBA8)
	for i in range(x_points.size()):
		var x = center.x + x_points[i]
		var y = center.y + y_points[i]
		#print("%s,%s" % [x,y])
		if x >= 0 and x < image_size.x and y >= 0 and y < image_size.y:
			image.set_pixel(x, y, range_color)
	image.set_pixelv(center, center_color)
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
