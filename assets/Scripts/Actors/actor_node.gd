class_name ActorNode
extends Node2D

var sprite:Sprite2D 
@onready var animation:AnimationPlayer = $AnimationPlayer

var Id:String 
var Actor:BaseActor 

func set_actor(actor:BaseActor):
	Id = actor.Id
	Actor = actor
	Actor.node = self
	if !sprite:
		sprite = $Sprite
	sprite.texture = actor.get_default_sprite()

func set_display_pos(pos:MapPos):
	if !sprite:
		sprite = $Sprite
	var rot = pos.dir
	if rot == 0: sprite.set_rotation_degrees(0) 
	if rot == 1: sprite.set_rotation_degrees(90) 
	if rot == 2: sprite.set_rotation_degrees(180) 
	if rot == 3: sprite.set_rotation_degrees(270) 
	pass

func play_shake():
	animation.play("shake_effect")
