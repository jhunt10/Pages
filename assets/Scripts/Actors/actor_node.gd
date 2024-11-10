class_name ActorNode
extends Node2D

@onready var animation:AnimationPlayer = $AnimationPlayer
@onready var animation_tree:AnimationTree = $AnimationTree

@onready var offset_node:Node2D = $ActorMotionNode/ActorSpriteNode/OffsetNode

@onready var actor_sprite:Sprite2D = $ActorMotionNode/ActorSpriteNode/OffsetNode/ActorSprite
@onready var main_hand_sprite:Sprite2D = $ActorMotionNode/ActorSpriteNode/OffsetNode/MainHandOverSprite
@onready var off_hand_sprite:Sprite2D = $ActorMotionNode/ActorSpriteNode/OffsetNode/OffHandOverlaySprite
@onready var two_hand_sprite:Sprite2D = $ActorMotionNode/ActorSpriteNode/OffsetNode/TwoHandOverSprite
@onready var main_hand_weapon_node:ActorWeaponNode = $ActorMotionNode/ActorSpriteNode/OffsetNode/MainHandOverSprite/MainHandWeaponNode
@onready var off_hand_weapon_node:ActorWeaponNode = $ActorMotionNode/ActorSpriteNode/OffsetNode/OffHandOverlaySprite/OffHandWeaponNode
@onready var two_hand_weapon_node:ActorWeaponNode = $ActorMotionNode/ActorSpriteNode/OffsetNode/TwoHandOverSprite/TwoHandWeaponNode

var Id:String 
var Actor:BaseActor 
var rot_dir
var start_walk_on_pos_change:bool

func _ready() -> void:
	animation.animation_started.connect(animation_started)
	animation.animation_finished.connect(animation_finished)

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
	offset_node.position = Vector2i(offset[0], offset[1])
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

#var delay_pos
#var still_waiting:bool
var delay_set_pos
var wait_more
var is_walking
func _process(delta: float) -> void:
	if delay_set_pos:
		if not wait_more: 
			#TODO: ????
			# Extra delay needed when SUB_ACTION_FRAME_TIME = 1.0 / 8.0 but not 11
			print("Set pos after delay")
			self.position = delay_set_pos
			delay_set_pos = null
			wait_more = false
		else:
			print("Waiting...")
			wait_more = true
	#if Actor.ActorKey != 'TestActor':
		#return
	#print("-------------------")
	
	#if delay_pos and animation.is_playing():
		#if still_waiting:
			#self.position = delay_pos
			#delay_pos = null
			#still_waiting = false
		#else:
			#still_waiting = true
		#print("CurAni: " + animation.current_animation)
	#else:
		#print("No Ani")
	#pass
	##if Actor.ActorKey == "TestActor":
		##printerr("Update")
		
func _load_nodes():
	if !actor_sprite:
		animation = $AnimationPlayer
		animation_tree = $AnimationTree
		offset_node = $ActorMotionNode/ActorSpriteNode/OffsetNode
		actor_sprite = $ActorMotionNode/ActorSpriteNode/OffsetNode/ActorSprite
		main_hand_sprite = $ActorMotionNode/ActorSpriteNode/OffsetNode/MainHandOverSprite
		off_hand_sprite = $ActorMotionNode/ActorSpriteNode/OffsetNode/OffHandOverlaySprite
		two_hand_sprite = $ActorMotionNode/ActorSpriteNode/OffsetNode/TwoHandOverSprite
		main_hand_weapon_node = $ActorMotionNode/ActorSpriteNode/OffsetNode/MainHandOverSprite/MainHandWeaponNode
		off_hand_weapon_node = $ActorMotionNode/ActorSpriteNode/OffsetNode/OffHandOverlaySprite/OffHandWeaponNode
		two_hand_weapon_node = $ActorMotionNode/ActorSpriteNode/OffsetNode/TwoHandOverSprite/TwoHandWeaponNode

func set_display_pos(pos:MapPos, start_walkin:bool=false):
	if Actor.ActorKey == 'TestActor':
		print("-------set_display_pos------------")
	_load_nodes()
	if !pos:
		return
	rot_dir = pos.dir
	
	if actor_sprite.vframes == 1:
		if rot_dir == 0: actor_sprite.set_rotation_degrees(0)
		if rot_dir == 1: actor_sprite.set_rotation_degrees(90)
		if rot_dir == 2: actor_sprite.set_rotation_degrees(180)
		if rot_dir == 3: actor_sprite.set_rotation_degrees(270) 
		var parent = get_parent()
		if parent is TileMapLayer:
			self.position = parent.map_to_local(Vector2i(pos.x, pos.y))
		return
	
	if !is_walking:
		animation.play("facing_"+get_animation_sufix())
	
	var parent = get_parent()
	if parent is TileMapLayer:
		var map_pos = parent.map_to_local(Vector2i(pos.x, pos.y))
		
		if is_walking:
			print("Seting Delay POs")
			delay_set_pos = map_pos
			start_walk_in_animation()
		else:
			print("HardSet pos")
			self.position = map_pos
	#elif !delay_pos:
		#fail_movement()
		
		#animation_tree.set("parameters/Facing/blend_position", pos.dir)
		#animation_tree.set("parameters/Walk_In/blend_position", pos.dir)
		#animation_tree.set("parameters/Walk_Out/blend_position", pos.dir)

func get_animation_sufix()->String:
	if rot_dir == 0: return "north"
	if rot_dir == 1: return "east"
	if rot_dir == 2: return "south"
	if rot_dir == 3: return "west"
	return "south"

func animation_finished(name):
	printerr("AnimationEnded: "+name)

func animation_started(name:String):
	if name.begins_with("walk_out_"):
		is_walking = true
	else:
		is_walking = false
	#if delay_pos :
		#self.position = delay_pos
		#delay_pos = null
	printerr("AnimationStarted: "+name)

func fail_movement():
	#printerr("fail Walk")
	#animation_tree.set("parameters/conditions/Walk", false)
	#animation_tree.set("parameters/conditions/FinishWalk", false)
	#animation_tree.set("parameters/conditions/MoveFailed", true)
	print("PlayConnecnd")
	animation.play("facing_"+get_animation_sufix())
	print("After_PlayConnecnd")
	

func play_shake():
	animation.play("shake_effect")

func start_walk_out_animation():
	printerr("Start Walk")
	animation.play("walk_out_"+get_animation_sufix())
	#animation_tree.set("parameters/conditions/Walk", true)
	#animation_tree.set("parameters/conditions/FinishWalk", false)
	#animation_tree.set("parameters/conditions/MoveFailed", false)
	
func start_walk_in_animation():
	printerr("Finish Walk")
	animation.play("walk_in_"+get_animation_sufix())
	#animation_tree.set("parameters/conditions/Walk", false)
	#animation_tree.set("parameters/conditions/FinishWalk", true)
	#animation_tree.set("parameters/conditions/MoveFailed", false)
