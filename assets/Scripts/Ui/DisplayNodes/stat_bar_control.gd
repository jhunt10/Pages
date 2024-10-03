class_name StatBarControl
extends Control

@onready var full_bar:NinePatchRect = $FullBarRect
@onready var bar_holder:Control = $BarHolder
@onready var real_value_bar:NinePatchRect = $BarHolder/RealValueRect
@onready var display_value_bar:NinePatchRect = $BarHolder/DisplayValueRect
@onready var preview_value_bar:NinePatchRect = $BarHolder/PreviewValueRect
@onready var animation:AnimationPlayer = $AnimationPlayer
@onready var label:Label = $Label

var max_value:int = 10
var real_value:int = 5
var preview_cost:int = -1
var display_value

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_values(80,100)
	preview_value_bar.visible = false
	pass # Replace with function body.

func set_values(cur_val:int, max_val:int, temp_value:int=-1):
	max_value = max_val
	real_value = cur_val
	display_value = temp_value
	if display_value < 0:
		display_value = real_value
	_sync()
	
func _sync():
	# No preview
	if preview_cost <= 0:
		real_value_bar.size.x = full_bar.size.x * real_value / max_value
		display_value_bar.size.x = full_bar.size.x * display_value / max_value
		display_value_bar.visible = display_value > 0
		real_value_bar.visible = real_value > 0
	label.text = str(real_value) + " / " + str(max_value)
		
	# Has preview
	if preview_cost > 0:
		var preview_val = display_value - preview_cost
		preview_value_bar.size.x = full_bar.size.x * preview_val / max_value
		real_value_bar.size.x = full_bar.size.x * real_value / max_value
		display_value_bar.size.x = full_bar.size.x * display_value / max_value
		preview_value_bar.visible = preview_val > 0
		display_value_bar.visible = display_value > 0
		real_value_bar.visible = real_value > 0
		label.text = str(preview_val) + " / " + str(display_value)
		
		
	
func set_color(color:Color):
	bar_holder.modulate = color

func play_preview_animation(cost:int):
	preview_cost = cost
	_sync()
	animation.play('blink_preview')

func stop_preview_animation():
	animation.stop(false)
	preview_cost = -1
	preview_value_bar.visible = false
	_sync()
