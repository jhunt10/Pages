@tool
extends Control

@export var min_x:int = 0
@export var max_x:int = 255
@export var max_y:int = 100

@export var grid_w:int = 10
@export var grid_h:int = 10

@export var do_draw:bool

@export var slider:HSlider
@export var point:ColorRect
@export var label:Label


const ARMOR_STRETCH:float = 30
const ARMOR_SCALE:float = 80
static func calc_armor_reduction(armor)->float:
	var log_x = log(armor)
	var val = (log((armor+ARMOR_STRETCH)/ARMOR_STRETCH) / log(10)) * ARMOR_SCALE
	return 1-(val/100)


func calc_val(x)->Vector2:
	var val = calc_armor_reduction(x)
	var y = 100 - (val * 100)
	return Vector2(x, y)


func _ready() -> void:
	slider.value_changed.connect(on_slider)

func _process(delta: float) -> void:
	if do_draw:
		queue_redraw()
		do_draw = false

func on_slider(slider_val):
	var val = calc_val(slider_val)
	point.position = Vector2(val.x, self.size.y - val.y)
	label.text = str(val)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_event = event as InputEventMouseMotion
		print(mouse_event.position)

func _draw() -> void:
	var grid_x = min_x
	while grid_x <= max_x:
		_draw_corrected_line(Vector2(grid_x, 0), Vector2(grid_x, self.size.y), Color.BLACK, 1.0)
		grid_x += grid_w
	var grid_y = 0
	while grid_y <= max_y:
		_draw_corrected_line(Vector2(0, grid_y), Vector2(self.size.x, grid_y), Color.BLACK, 1.0)
		grid_y += grid_h
	
	for i in range(min_x, max_x):
		var x = (self.size.x / (max_x-min_x)) * i
		var next_x = (self.size.x / (max_x-min_x)) * (i+1)
		var val = calc_val(x)
		_draw_corrected_line(val, Vector2(next_x, val.y), Color.GREEN, 1.0)
		print(str(val))

func _draw_corrected_line(a:Vector2, b:Vector2, color:Color, width:float):
	var real_a = Vector2(a.x, self.size.y - a.y)
	var real_b = Vector2(b.x, self.size.y - b.y)
	draw_line(real_a, real_b, color, width)