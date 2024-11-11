class_name ActorWeaponNode
extends Node2D

@export var hand_name:String
@export var force_rotation:bool

var _wpn_sprt
var weapon_sprite:Sprite2D:
	get: 
		if !_wpn_sprt: _wpn_sprt = get_child(0)
		return _wpn_sprt
var _ovr_sprt
var overhand_weapon_sprite:Sprite2D:
	get: 
		if !_ovr_sprt: _ovr_sprt = get_child(1)
		return _ovr_sprt

var _rest_sprite_rotation:float

func _process(delta: float) -> void:
	if force_rotation and weapon_sprite.rotation_degrees != 0:
		self.weapon_sprite.rotation_degrees = 0
		self.overhand_weapon_sprite.rotation_degrees = 0
	elif not force_rotation and weapon_sprite.rotation_degrees != _rest_sprite_rotation:
		self.weapon_sprite.rotation_degrees = _rest_sprite_rotation
		self.overhand_weapon_sprite.rotation_degrees = _rest_sprite_rotation
		
		

func set_weapon(weapon:BaseWeaponEquipment):
	var sprite_data:Dictionary = weapon.get_load_val("WeaponSpriteData", {})
	if sprite_data.size() == 0:
		self.visible = false
		return
	else:
		self.visible = true
	
	var sprite_base_path = weapon._def_load_path.path_join(sprite_data.get("SpriteName"))
	var sprite_file = sprite_base_path + ".png"
	var overhand_sprite_file = sprite_base_path + "_OverHand.png"
	
	self.weapon_sprite.texture = SpriteCache.get_sprite(sprite_file)
	self.overhand_weapon_sprite.texture = SpriteCache.get_sprite(overhand_sprite_file)
	
	var offset_arr = sprite_data.get("Offset", [0,0])
	var offset = Vector2i(offset_arr[0], offset_arr[1])
	self.weapon_sprite.offset = offset
	self.overhand_weapon_sprite.offset = offset
	
	_rest_sprite_rotation = sprite_data.get("Rotation", 0)
	self.weapon_sprite.rotation_degrees = _rest_sprite_rotation
	self.overhand_weapon_sprite.rotation_degrees = _rest_sprite_rotation

func on_animation_end(animation_name:String):
	#if animation_name.begins_with("swing_motion_"):
		#self.weapon_sprite.rotation_degrees = _rest_sprite_rotation
		#self.overhand_weapon_sprite.rotation_degrees = _rest_sprite_rotation
	pass

func on_animation_start(animation_name:String):
	#if animation_name.contains(hand_name):
		#self.weapon_sprite.rotation_degrees = 0
		#self.overhand_weapon_sprite.rotation_degrees = 0
	#else:
		#self.weapon_sprite.rotation_degrees = _rest_sprite_rotation
		#self.overhand_weapon_sprite.rotation_degrees = _rest_sprite_rotation
	pass
