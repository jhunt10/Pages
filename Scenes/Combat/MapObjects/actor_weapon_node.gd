@tool
class_name ActorWeaponNode
extends Node2D

const LOGGING = false

var parent_sprite:Sprite2D:
	get:
		if !parent_sprite:
			parent_sprite =  $".."
		return parent_sprite

var animation:AnimationPlayer:
	get: 
		if !animation:
			animation = $"../AnimationPlayer"
		return animation

var _lock_position_edit:bool = false
@export var edit_mode:bool:
	set(val):
		edit_mode = val
		if edit_mode:
			self.modulate = Color.RED
		else:
			self.modulate = Color.WHITE
@export var hand:ActorHandNode.HANDS:
	set(val):
		hand = val
		if hand == ActorHandNode.HANDS.MainHand:
			main_hand_position = main_hand_position
			self.flip_sprite = false
		if hand == ActorHandNode.HANDS.OffHand:
			off_hand_offset = off_hand_offset
			self.flip_sprite = true
		if hand == ActorHandNode.HANDS.TwoHand:
			two_hand_offset = two_hand_offset
			self.flip_sprite = false
@export var flip_sprite:bool:
	set(val):
		flip_sprite = val
		if flip_sprite and !unflip_offhand:
			overhand_weapon_sprite.scale = Vector2(-1,1)
			underhand_weapon_sprite.scale = Vector2(-1,1)
		else:
			overhand_weapon_sprite.scale = Vector2(1,1)
			underhand_weapon_sprite.scale = Vector2(1,1)
@export var unflip_offhand:bool:
	set(val):
		unflip_offhand = val
		if flip_sprite and !unflip_offhand:
			overhand_weapon_sprite.scale = Vector2(-1,1)
			underhand_weapon_sprite.scale = Vector2(-1,1)
		else:
			overhand_weapon_sprite.scale = Vector2(1,1)
			underhand_weapon_sprite.scale = Vector2(1,1)
		
#@export var hand_name:String
@export var main_hand_position:Vector2:
	set(val):
		if LOGGING: print("Set MainHand Pos")
		main_hand_position = val
		if not edit_mode and hand == ActorHandNode.HANDS.MainHand:
			self.position = main_hand_position
		elif edit_mode and hand != ActorHandNode.HANDS.MainHand:
			self.position = main_hand_position
			
@export var off_hand_offset:Vector2:
	set(val):
		if LOGGING: print("Set OffHand Pos")
		off_hand_offset = val
		if hand == ActorHandNode.HANDS.OffHand:
			self.position = main_hand_position - off_hand_offset
@export var two_hand_offset:Vector2:
	set(val):
		if LOGGING: print("Set Two Pos")
		two_hand_offset = val
		if hand == ActorHandNode.HANDS.TwoHand:
			self.position = main_hand_position - two_hand_offset

@export var overhand_weapon_sprite:Sprite2D
@export var underhand_weapon_sprite:Sprite2D

## Ratio between natural Node rotation and custom Sprite rotation
## At rotation_factor = 0, the sprite's rotation will match the nodes
## At roation factor = 1, the sprite's rotation will match custom_rotation
@export var rotation_factor:float:
	set(val):  
		rotation_factor = val
		if self.overhand_weapon_sprite:
			var rot_degs = self.rotation_degrees
			if flip_sprite or self.scale.x < 0:
				rot_degs = -rot_degs
			var target_rotation:float = (custom_rotation - rot_degs) * rotation_factor
			if overhand_weapon_sprite.rotation_degrees != target_rotation:
				if LOGGING: print("Setting Rotation: cur:%s | cust:%s | fact:%s | result: %s " % [self.rotation_degrees, custom_rotation, rotation_factor, target_rotation])
				self.overhand_weapon_sprite.rotation_degrees = target_rotation
				self.underhand_weapon_sprite.rotation_degrees = target_rotation
@export var custom_rotation:int:
	set(val):  
		custom_rotation = val
		if self.overhand_weapon_sprite:
			var target_rotation:float = rotation_factor * custom_rotation + self.rotation_degrees 
			if overhand_weapon_sprite.rotation_degrees != target_rotation:
				if LOGGING: print("Setting Rotation: " + str(target_rotation))
				self.overhand_weapon_sprite.rotation_degrees = target_rotation
				self.underhand_weapon_sprite.rotation_degrees = target_rotation

@export var weapon_texture:Texture2D:
	set(val):
		weapon_texture = val
		if self.overhand_weapon_sprite:
			self.overhand_weapon_sprite.texture = weapon_texture
			self.underhand_weapon_sprite.texture = weapon_texture

func _init() -> void:
	set_notify_transform(true)

var last_pos:Vector2
func _notification(what):
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		if last_pos != self.position:
			last_pos = self.position
			# Edit Mode
			if edit_mode:
				if hand == ActorHandNode.HANDS.MainHand:
					main_hand_position = self.position
				elif  hand == ActorHandNode.HANDS.OffHand:
					off_hand_offset = main_hand_position - self.position
				elif  hand == ActorHandNode.HANDS.TwoHand:
					two_hand_offset = main_hand_position - self.position
			#else:
				#if  hand == HANDS.OffHand:
					#self.position = self.position - off_hand_offset
				#elif  hand == HANDS.TwoHand:
					#self.position = self.position - two_hand_offset
			

func set_weapon(weapon:BaseWeaponEquipment):
	var sprite_data:Dictionary = weapon.get_load_val("WeaponSpriteData", {})
	if sprite_data.size() == 0:
		self.visible = false
		return
	else:
		self.visible = true
	
	var sprite_base_path = weapon._def_load_path.path_join(sprite_data.get("SpriteName"))
	var sprite_file = sprite_base_path + "_WeaponSprite.png"
	
	self.weapon_texture = SpriteCache.get_sprite(sprite_file)
	
	var offset_arr = sprite_data.get("Offset", [0,0])
	var offset = Vector2i(offset_arr[0], offset_arr[1])
	self.overhand_weapon_sprite.offset = offset
	self.underhand_weapon_sprite.offset = offset
	
	custom_rotation = sprite_data.get("Rotation", 0)
	self.overhand_weapon_sprite.rotation_degrees = custom_rotation
	self.underhand_weapon_sprite.rotation_degrees = custom_rotation
