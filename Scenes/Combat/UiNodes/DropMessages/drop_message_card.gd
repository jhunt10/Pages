class_name DropMessageCard
extends Control

signal finished

@export var show_time:float = 2
@export var fade_speed:float = 3

@export var icon_background:TextureRect
@export var icon_rect:TextureRect
@export var label:Label

var _is_finiashed:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _is_finiashed or not self.visible:
		return
	elif show_time > 0:
		show_time -= delta
	elif self.modulate.a > 0:
		self.modulate.a -= fade_speed * delta
	else:
		_is_finiashed = true
		finished.emit()
