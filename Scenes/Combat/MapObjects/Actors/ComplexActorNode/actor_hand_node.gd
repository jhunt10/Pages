@tool
class_name ActorHandNode
extends Node2D

const LOGGING = false

enum HANDS {MainHand, OffHand, TwoHand}
enum ANIMATIONS {None, Swing, Stab}

@export var editing_mod:bool = false

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

@export var facing_dir:MapPos.Directions:
	set(val):
		if val != facing_dir:
			facing_dir = val
			set_facing_dir(val)

@export var animation_is_ready:bool
@export var main_hand_sprite_sheet:Texture2D
@export var off_hand_sprite_sheet:Texture2D
@export var two_hand_sprite_sheet:Texture2D
@export var animation_tree:AnimationTree
@export var hand_sprite:Sprite2D
@export var weapon_node:ActorWeaponNode
@export var animation_speed:float = -1

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

var current_animation_name
var last_animation_name
var readied_animation

func _init() -> void:
	set_notify_transform(true)

func _ready() -> void:
	animation_tree.animation_started.connect(on_animation_started)
	animation_tree.animation_finished.connect(on_animation_finished)

func _process(delta: float) -> void:
	if editing_mod and Engine.is_editor_hint():
		return
	var time_scale = CombatRootControl.get_time_scale()
	if animation_speed > 0:
		time_scale = time_scale * animation_speed
	animation_tree.advance(delta * time_scale)

func set_weapon(weapon:BaseWeaponEquipment):
	weapon_node.visible = true
	weapon_node.set_weapon(weapon)

func hide_weapon():
	weapon_node.visible = false

func ready_arnimation(name, speed:float=1.0):
	animation_tree.set("parameters/conditions/Cancel", false)
	animation_tree.set("parameters/conditions/PlayMotion", false)
	if name == "Swing":
		animation_tree.set("parameters/conditions/Swing", true)
		readied_animation = name
		animation_speed = speed
	if name == "Stab":
		animation_tree.set("parameters/conditions/Stab", true)
		readied_animation = name
		animation_speed = speed
	if name == "Raise":
		animation_tree.set("parameters/conditions/Raise", true)
		readied_animation = name
		animation_speed = speed

func execute_animation(speed:float=1.0):
	if not readied_animation:
		printerr("ActorHandNode.execute_animation: Called with no readied_animation.")
		return
	animation_speed = speed
	readied_animation = null
	animation_tree.set("parameters/conditions/PlayMotion", true)
	printerr("Set Motion")
	printerr("HandAnimation Executing: Cancel:%s | PlayMotion: %s" % 
	[animation_tree.get("parameters/conditions/Cancel"), animation_tree.get("parameters/conditions/PlayMotion")])

func cancel_animation():
	readied_animation = null
	animation_tree.set("parameters/conditions/Cancel", true)

#func clear_any_animations(dir_sufix):
	#readied_animation = null
	#animation_tree.set("parameters/conditions/Cancel", true)

func on_animation_started(animation_name):
	current_animation_name = animation_name
	if animation_name.contains("facing"):
		animation_speed = 1
	if LOGGING: printerr("HandAnimation Started: %s | Cancel:%s | PlayMotion: %s" % [
		animation_name, 
		animation_tree.get("parameters/conditions/Cancel"), 
		animation_tree.get("parameters/conditions/PlayMotion")])
	
func on_animation_finished(animation_name):
	current_animation_name = null
	last_animation_name = animation_name
	if LOGGING: printerr("HandAnimation Finished: %s | Cancel:%s | PlayMotion: %s" % [
		animation_name, 
		animation_tree.get("parameters/conditions/Cancel"), 
		animation_tree.get("parameters/conditions/PlayMotion")])


func set_facing_dir(dir):
	if dir != facing_dir:
		facing_dir = dir
		return # Avoid Stack Overflow
		
	if dir == MapPos.Directions.North:
		if hand == HANDS.MainHand or hand == HANDS.TwoHand:
			hand_z_offset = 0
			weapon_z_offset = 0
			weapon_under_hand_z_offset = 1
			weapon_over_hand_z_offset = -1
			if weapon_node:
				weapon_node.flip_sprite = false
		if hand == HANDS.OffHand:
			hand_z_offset = 1
			weapon_z_offset = 0
			weapon_under_hand_z_offset = 2
			weapon_over_hand_z_offset = 0
			if weapon_node:
				weapon_node.flip_sprite = true
		if hand_sprite and hand_sprite.vframes == 4:
			hand_sprite.frame_coords.y = 1
	
	if dir == MapPos.Directions.East:
		if weapon_node:
			weapon_node.flip_sprite = false
		if hand == HANDS.MainHand or hand == HANDS.TwoHand:
			hand_z_offset = 1
			weapon_z_offset = 1
			weapon_under_hand_z_offset = -1
			weapon_over_hand_z_offset = 1
		if hand == HANDS.OffHand:
			hand_z_offset = 0
			weapon_z_offset = 1
			weapon_under_hand_z_offset = 2
			weapon_over_hand_z_offset = 0
		if hand_sprite and hand_sprite.vframes == 4:
			hand_sprite.frame_coords.y = 2
	
	if dir == MapPos.Directions.South:
		if hand == HANDS.MainHand or hand == HANDS.TwoHand:
			hand_z_offset = 0
			weapon_z_offset = 1
			weapon_under_hand_z_offset = -1
			weapon_over_hand_z_offset = 1
			if weapon_node:
				weapon_node.flip_sprite = false
		if hand == HANDS.OffHand:
			hand_z_offset = 0
			weapon_z_offset = 1
			weapon_under_hand_z_offset = -1
			weapon_over_hand_z_offset = 1
			if weapon_node:
				weapon_node.flip_sprite = true
		if hand_sprite and hand_sprite.vframes == 4:
			hand_sprite.frame_coords.y = 0
	
	if dir == MapPos.Directions.West:
		if weapon_node:
			weapon_node.flip_sprite = false
		if hand == HANDS.MainHand:
			hand_z_offset = 0
			weapon_z_offset = 1
			weapon_under_hand_z_offset = -1
			weapon_over_hand_z_offset = 1
		if hand == HANDS.OffHand or hand == HANDS.TwoHand:
			hand_z_offset = 0
			weapon_z_offset = 1
			weapon_under_hand_z_offset = -1
			weapon_over_hand_z_offset = 1
		if hand_sprite and hand_sprite.vframes == 4:
			hand_sprite.frame_coords.y = 3
	
	if animation_tree:
		animation_tree.set("parameters/Idel/blend_position", dir)
		animation_tree.set("parameters/SwingReady/blend_position", dir)
		animation_tree.set("parameters/SwingMotion/blend_position", dir)
		animation_tree.set("parameters/SwingCancel/blend_position", dir)
		animation_tree.set("parameters/StabReady/blend_position", dir)
		animation_tree.set("parameters/StabMotion/blend_position", dir)
		animation_tree.set("parameters/StabCancel/blend_position", dir)
		animation_tree.set("parameters/RaiseReady/blend_position", dir)
		animation_tree.set("parameters/RaiseMotion/blend_position", dir)
		animation_tree.set("parameters/RaiseCancel/blend_position", dir)
