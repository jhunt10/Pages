class_name FlashTextControl
extends Control

@onready var label:Label = $Label

var min_time = 0.25
var end_time = 0.7
var speed_scale = 0.8
var timer = 0

var velocity = 2.0
var gravity = 1.5
var phyics_scale = 2

var _text:String
var _color:Color

func _ready():
	label.text = _text
	label.modulate = _color
	pass

func _process(delta):
	timer += delta * speed_scale
	label.position.y -= velocity
	velocity -= gravity * delta * phyics_scale
	var fade_out = (float(end_time - (timer - min_time)) / float(end_time - min_time))
	label.modulate.a =fade_out
	if fade_out <= 0:
		self.queue_free()
	pass

func set_values(val:String, color:Color):
	self._text = val
	self._color = color
