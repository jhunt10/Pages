class_name ActorNode
extends Node2D

var sprite:Sprite2D 
@onready var animation:AnimationPlayer = $AnimationPlayer

var Id:String 
var Actor:BaseActor 
var rot_dir
var start_walk_on_pos_change:bool

func set_actor(actor:BaseActor):
	Id = actor.Id
	Actor = actor
	Actor.node = self
	if !sprite:
		sprite = $Sprite
	sprite.texture = actor.get_sprite()
	var frames = actor.get_load_val("SpriteFrameWH", [1,1])
	sprite.hframes = frames[0]
	sprite.vframes = frames[1]
	var offset = actor.get_load_val("SpriteOffset", [0,0])
	sprite.position = Vector2(offset[0], offset[1])

func _process(delta: float) -> void:
	pass
	#if Actor.ActorKey == "TestActor":
		#printerr("Update")

func set_display_pos(pos:MapPos, start_walkin:bool=false):
	if !sprite:
		sprite = $Sprite
	if !pos:
		return
	var tile_map:TileMapLayer = get_parent()
	if tile_map:
		var map_pos = tile_map.map_to_local(Vector2i(pos.x, pos.y))
		self.position = map_pos
	rot_dir = pos.dir
	if sprite.vframes == 1:
		if rot_dir == 0: sprite.set_rotation_degrees(0) 
		if rot_dir == 1: sprite.set_rotation_degrees(90) 
		if rot_dir == 2: sprite.set_rotation_degrees(180) 
		if rot_dir == 3: sprite.set_rotation_degrees(270) 
	else:
		if rot_dir == 0: sprite.frame = 3
		if rot_dir == 1: sprite.frame = 6 
		if rot_dir == 2: sprite.frame = 0
		if rot_dir == 3: sprite.frame = 9 
	if start_walkin:
		start_walk_in_animation()

func play_shake():
	animation.play("shake_effect")

func start_walk_out_animation():
	if rot_dir == 0: animation.play("walk_north_out")
	if rot_dir == 1: animation.play("walk_east_out")
	if rot_dir == 2: animation.play("walk_south_out")
	if rot_dir == 3: animation.play("walk_west_out")
	
func start_walk_in_animation():
	if rot_dir == 0: animation.play("walk_north_in")
	if rot_dir == 1: animation.play("walk_east_in")
	if rot_dir == 2: animation.play("walk_south_in")
	if rot_dir == 3: animation.play("walk_west_in")
