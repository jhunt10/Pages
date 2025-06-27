class_name FlashTextNode
extends Label

signal finished

var min_time = 0.25
var end_time = 1#0.7
var speed_scale = 0.8
var timer = 0

var velocity = 1.0
var gravity = 1.5
var phyics_scale = 2
var x_velocity:float = 0
var max_x_velocity:float = 1.5

var id:String
var parent_controller:FlashTextController
var started:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	x_velocity = max_x_velocity * (randf() - 0.5) 
	pass # Replace with function body.


func _process(delta):
	if not started:
		return
	timer += delta * speed_scale
	self.position.y -= velocity
	self.position.x += x_velocity
	velocity -= gravity * delta * phyics_scale
	var fade_out = (float(end_time - (timer - min_time)) / float(end_time - min_time))
	self.modulate.a =fade_out
	if fade_out <= 0:
		finished.emit()
