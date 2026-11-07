class_name LevelUpButtonControl
extends Control

signal pressed

@export var animation_player:AnimationPlayer
@export var button:Button
@export var other_button:LevelUpButtonControl

var _actor:BaseActor
var _been_clicked_while_flashing:bool=false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.pressed.connect(_on_button_pressed.bind(false))
	if other_button:
		other_button.pressed.connect(_on_button_pressed.bind(true))
	pass # Replace with function body.

func set_actor(actor:BaseActor):
	_actor = actor
	sync()

func sync():
	if !animation_player:
		return
	if !_actor:
		animation_player.play('waiting')
		return
		
	var unspent_count = _actor.get_unspent_skill_points()
	if unspent_count > 0:
		if _been_clicked_while_flashing:
			animation_player.play('plus')
		else:
			animation_player.play('flashing_animation')
	else:
		animation_player.play('waiting')

func _on_button_pressed(other_button:bool):
	_been_clicked_while_flashing = true
	sync()
	if not other_button:
		pressed.emit()
