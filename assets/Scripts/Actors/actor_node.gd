class_name ActorNode
extends Node2D

@onready var animation:AnimationPlayer = $AnimationPlayer
@onready var animation_tree:AnimationTree = $AnimationTree

@onready var actor_sprite:Sprite2D = $ActorSpriteNode/ActorSprite
@onready var main_hand_sprite:Sprite2D = $ActorSpriteNode/MainHandOverSprite
@onready var off_hand_sprite:Sprite2D = $ActorSpriteNode/OffHandOverlaySprite
@onready var two_hand_sprite:Sprite2D = $ActorSpriteNode/TwoHandOverSprite
@onready var main_hand_weapon_node:ActorWeaponNode = $ActorSpriteNode/MainHandOverSprite/MainHandWeaponNode
@onready var off_hand_weapon_node:ActorWeaponNode = $ActorSpriteNode/OffHandOverlaySprite/OffHandWeaponNode
@onready var two_hand_weapon_node:ActorWeaponNode = $ActorSpriteNode/TwoHandOverSprite/TwoHandWeaponNode

var Id:String 
var Actor:BaseActor 
var rot_dir
var start_walk_on_pos_change:bool

func set_actor(actor:BaseActor):
	Id = actor.Id
	Actor = actor
	Actor.node = self
	_load_nodes()
	var frames = actor.get_load_val("SpriteFrameWH", [1,1])
	actor_sprite.hframes = frames[0]
	actor_sprite.vframes = frames[1]
	main_hand_sprite.hframes = frames[0]
	main_hand_sprite.vframes = frames[1]
	off_hand_sprite.hframes = frames[0]
	off_hand_sprite.vframes = frames[1]
	two_hand_sprite.hframes = frames[0]
	two_hand_sprite.vframes = frames[1]
	var offset = actor.get_load_val("SpriteOffset", [0,0])
	actor_sprite.position = Vector2(offset[0], offset[1])
	main_hand_sprite.position = Vector2(offset[0], offset[1])
	off_hand_sprite.position = Vector2(offset[0], offset[1])
	two_hand_sprite.position = Vector2(offset[0], offset[1])
	sync_sprites()
	if not actor.equipment.equipment_changed.is_connected(sync_sprites):
		actor.equipment.equipment_changed.connect(sync_sprites)

func sync_sprites():
	actor_sprite.texture = Actor.get_body_sprite()
	main_hand_sprite.texture = Actor.get_main_hand_sprite()
	off_hand_sprite.texture = Actor.get_off_hand_sprite()
	two_hand_sprite.texture = Actor.get_two_hand_sprite()
	
	if Actor.equipment.is_two_handing():
		main_hand_sprite.visible = false
		off_hand_sprite.visible = false
		two_hand_sprite.visible = true
		
		var two_hand_weapon = Actor.equipment.get_primary_weapon()
		if two_hand_weapon:
			print("Loading 2hand primarty: " + two_hand_weapon.Id)
			_load_weapon_sprite(two_hand_weapon_node, two_hand_weapon)
		else:
			two_hand_weapon_node.visible = false
	else:
		main_hand_sprite.visible = true
		off_hand_sprite.visible = true
		two_hand_sprite.visible = false
		var main_hand_weapon = Actor.equipment.get_primary_weapon()
		if main_hand_weapon:
			_load_weapon_sprite(main_hand_weapon_node, main_hand_weapon)
		else:
			main_hand_weapon_node.visible = false
			
		var off_hand_weapon = Actor.equipment.get_offhand_weapon()
		if off_hand_weapon:
			_load_weapon_sprite(off_hand_weapon_node, off_hand_weapon)
		else:
			off_hand_weapon_node.visible = false
		

func _load_weapon_sprite(weapon_node:ActorWeaponNode, weapon:BaseWeaponEquipment):
	var sprite_data:Dictionary = weapon.get_load_val("WeaponSpriteData", {})
	if sprite_data.size() == 0:
		weapon_node.visible = false
		return
	weapon_node.visible = true
	var sprite_base_path = weapon._def_load_path.path_join(sprite_data.get("SpriteName"))
	var sprite_file = sprite_base_path + ".png"
	var overhand_sprite_file = sprite_base_path + "_OverHand.png"
	weapon_node.weapon_sprite.texture = SpriteCache.get_sprite(sprite_file)
	weapon_node.overhand_weapon_sprite.texture = SpriteCache.get_sprite(overhand_sprite_file)
	
	var rotation = sprite_data.get("Rotation", 0)
	weapon_node.weapon_sprite.rotation_degrees = rotation
	weapon_node.overhand_weapon_sprite.rotation_degrees = rotation
	var offset_arr = sprite_data.get("Offset", [0,0])
	var offset = Vector2i(offset_arr[0], offset_arr[1])
	weapon_node.weapon_sprite.offset = offset
	weapon_node.overhand_weapon_sprite.offset = offset

func _process(delta: float) -> void:
	pass
	#if Actor.ActorKey == "TestActor":
		#printerr("Update")
		
func _load_nodes():
	if !actor_sprite:
		animation = $AnimationPlayer
		animation_tree = $AnimationTree
		actor_sprite = $ActorSpriteNode/ActorSprite
		main_hand_sprite = $ActorSpriteNode/MainHandOverSprite
		off_hand_sprite = $ActorSpriteNode/OffHandOverlaySprite
		two_hand_sprite = $ActorSpriteNode/TwoHandOverSprite
		main_hand_weapon_node = $ActorSpriteNode/MainHandOverSprite/MainHandWeaponNode
		off_hand_weapon_node = $ActorSpriteNode/OffHandOverlaySprite/OffHandWeaponNode
		two_hand_weapon_node = $ActorSpriteNode/TwoHandOverSprite/TwoHandWeaponNode

func set_display_pos(pos:MapPos, start_walkin:bool=false):
	_load_nodes()
	if !pos:
		return
	var parent = get_parent()
	if parent is TileMapLayer:
		var tile_map:TileMapLayer = parent
		if tile_map:
			var map_pos = tile_map.map_to_local(Vector2i(pos.x, pos.y))
			self.position = map_pos
	rot_dir = pos.dir
	if actor_sprite.vframes == 1:
		if rot_dir == 0: actor_sprite.set_rotation_degrees(0) 
		if rot_dir == 1: actor_sprite.set_rotation_degrees(90) 
		if rot_dir == 2: actor_sprite.set_rotation_degrees(180) 
		if rot_dir == 3: actor_sprite.set_rotation_degrees(270) 
	else:
		animation_tree.set("parameters/Facing/blend_position", pos.dir)
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
	if rot_dir == 1: animation.play("walk_east_in_new")
	if rot_dir == 2: animation.play("walk_south_in")
	if rot_dir == 3: animation.play("walk_west_in")
