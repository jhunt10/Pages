class_name ActorPlacerButton
extends Node

signal pressed

@export var highlight:TextureRect
@export var actor_icon:TextureRect
@export var button:Button
var actor_id:String = ''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if button:
		button.pressed.connect(pressed.emit)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
