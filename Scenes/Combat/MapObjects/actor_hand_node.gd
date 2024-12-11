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
		elif LOGGING: print("NoWeaponNode")
	get:
		if self.weapon_node: return self.hand_sprite.z_index
		else: return 0
		
@export var weapon_z_offset:int:
	set(val):
		if self.weapon_node: self.weapon_node.z_index = val
		elif LOGGING: print("NoWeaponNode")
	get:
		if self.weapon_node: return self.weapon_node.z_index
		else: return 0

@export var weapon_under_hand_z_offset:int:
	set(val):
		if self.weapon_node: self.weapon_node.underhand_weapon_sprite.z_index = val
		elif LOGGING: print("NoWeaponNode")
	get:
		if self.weapon_node: return self.weapon_node.underhand_weapon_sprite.z_index
		else: return 0

@export var weapon_over_hand_z_offset:int:
	set(val):
		if self.weapon_node: self.weapon_node.overhand_weapon_sprite.z_index = val
		elif LOGGING: print("NoWeaponNode")
	get:
		if self.weapon_node: return self.weapon_node.overhand_weapon_sprite.z_index
		else: return 0

@export var two_hand_z_west_override:bool:
	set(val):
		two_hand_z_west_override = val
		if two_hand_z_west_override and self.hand == HANDS.TwoHand: 
			self.z_index = 3
			if weapon_node:
				weapon_node.z_index = 1
				weapon_node.underhand_weapon_sprite.z_index = -1
				weapon_node.overhand_weapon_sprite.z_index = 1
		elif LOGGING: print("NoWeaponNode")

var current_animation

func _init() -> void:
	set_notify_transform(true)

func set_weapon(weapon:BaseWeaponEquipment):
	weapon_node.visible = true
	weapon_node.set_weapon(weapon)

func hide_weapon():
	weapon_node.visible = false

func ready_arnimation(name, dir_sufix):
	var animation_name = name + "/ready" + dir_sufix
	if not animation.has_animation(animation_name):
		printerr("No ActorHand animation found with name: %s" % [animation_name])
		return
	animation.play(animation_name)
	current_animation = animation_name

func execute_animation():
	if not current_animation:
		printerr("ActorHandNode.execute_animation: Called with no current_animation.")
		return
	if current_animation.contains("/ready_"):
		current_animation = current_animation.replace("/ready_", "/motion_")
		animation.play(current_animation)

func cancel_animation():
	if current_animation.contains("/ready_"):
		current_animation = current_animation.replace("/ready_", "/cancel_")
		animation.play(current_animation)

func clear_any_animations(dir_sufix):
	animation.play("weapon_facing/facing" + dir_sufix)

func on_animation_finished(finished):
	# Hold onto the "ready" animation since the actor is holding the pose
	if finished.contains("/ready_"):
		return
	if current_animation == finished:
		current_animation = null
	else:
		printerr("Hand Animation mismatch: Current: %s | Finshed: %s" % [current_animation, finished])
	
