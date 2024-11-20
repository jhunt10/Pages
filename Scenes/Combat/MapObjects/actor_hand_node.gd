@tool
class_name ActorHandNode
extends Node2D

const LOGGING = false

enum HANDS {MainHand, OffHand, TwoHand}

@export var hand:HANDS:
	set(val):
		hand = val
		if weapon_node:
			weapon_node.hand = val
		if !hand_sprite:
			return
		if hand == HANDS.MainHand:
			hand_sprite.texture = main_hand_sprite_sheet
		if hand == HANDS.OffHand:
			hand_sprite.texture = off_hand_sprite_sheet
		if hand == HANDS.TwoHand:
			hand_sprite.texture = two_hand_sprite_sheet

@export var main_hand_sprite_sheet:Texture2D
@export var off_hand_sprite_sheet:Texture2D
@export var two_hand_sprite_sheet:Texture2D

@export var animation:AnimationPlayer
@export var hand_sprite:Sprite2D
@export var weapon_node:ActorWeaponNode


@export var hand_z_offset:int:
	set(val):
		if self.weapon_node: self.hand_sprite.z_index = val
		else: print("NoWeaponNode")
	get:
		if self.weapon_node: return self.hand_sprite.z_index
		else: return 0
		
@export var weapon_z_offset:int:
	set(val):
		if self.weapon_node: self.weapon_node.z_index = val
		else: print("NoWeaponNode")
	get:
		if self.weapon_node: return self.weapon_node.z_index
		else: return 0

@export var weapon_under_hand_z_offset:int:
	set(val):
		if self.weapon_node: self.weapon_node.underhand_weapon_sprite.z_index = val
		else: print("NoWeaponNode")
	get:
		if self.weapon_node: return self.weapon_node.underhand_weapon_sprite.z_index
		else: return 0

@export var weapon_over_hand_z_offset:int:
	set(val):
		if self.weapon_node: self.weapon_node.overhand_weapon_sprite.z_index = val
		else: print("NoWeaponNode")
	get:
		if self.weapon_node: return self.weapon_node.overhand_weapon_sprite.z_index
		else: return 0

func _init() -> void:
	set_notify_transform(true)

func set_weapon(weapon:BaseWeaponEquipment):
	weapon_node.visible = true
	weapon_node.set_weapon(weapon)

func hide_weapon():
	weapon_node.visible = false
