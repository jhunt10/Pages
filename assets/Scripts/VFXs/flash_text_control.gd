class_name FlashTextControl
extends Control

@export var numbers_texture:Texture2D
@onready var label:Label = $Label

@export var numbers_container:HBoxContainer
@export var premade_number:TextureRect

static var cached_textures:Dictionary = {}

var min_time = 0.25
var end_time = 0.7
var speed_scale = 0.8
var timer = 0

var velocity = 2.0
var gravity = 1.5
var phyics_scale = 2
var x_velocity:float = 0
var max_x_velocity:float = 1.5

var _text:String
var _color:Color

func _ready():
	label.text = _text
	label.modulate = _color
	x_velocity = max_x_velocity * (randf() - 0.5) 
	premade_number.hide()
	pass

func _process(delta):
	timer += delta * speed_scale
	label.position.y -= velocity
	label.position.x += x_velocity
	velocity -= gravity * delta * phyics_scale
	var fade_out = (float(end_time - (timer - min_time)) / float(end_time - min_time))
	label.modulate.a =fade_out
	if fade_out <= 0:
		self.queue_free()
	pass

func set_values(val:String, color:Color):
	slice_texture()
	if val.begins_with("+") or val.begins_with("-"):
		for i in range(val.length()):
			var char = val.substr(i,1)
			var texture = cached_textures.get(char)
			if texture:
				var new_rect = premade_number.duplicate()
				new_rect.texture = texture
				new_rect.show()
				numbers_container.add_child(new_rect)
	else:
		self._text = val
	self._color = color

func slice_texture():
	if cached_textures.size() > 0:
		return
	var base_image = numbers_texture.get_image()
	for i in range(12):
		var rect = Rect2i(i * 40, 0, 40, 56)
		var sub_image = base_image.get_region(rect)
		var new_texture = ImageTexture.create_from_image(sub_image)
		if i < 10:
			cached_textures[str(i)] = new_texture
		if i == 10:
			cached_textures['-'] = new_texture
		if i == 11:
			cached_textures['+'] = new_texture
