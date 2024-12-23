@tool
class_name ActorHandNode
extends Node2D

const LOGGING = false

enum HANDS {MainHand, OffHand, TwoHand}
enum ANIMATIONS {None, Swing, Stab}

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
		facing_dir = val
		set_facing_dir(val)
		if animation_tree:
			animation_tree.set("parameters/Idel/blend_position", facing_dir)
			animation_tree.set("parameters/SwingReady/blend_position", facing_dir)
			animation_tree.set("parameters/SwingMotion/blend_position", facing_dir)
			animation_tree.set("parameters/SwingCancel/blend_position", facing_dir)
			animation_tree.set("parameters/StabReady/blend_position", facing_dir)
			animation_tree.set("parameters/StabMotion/blend_position", facing_dir)
			animation_tree.set("parameters/StabCancel/blend_position", facing_dir)

# For editing
#@export var ready_animation:ANIMATIONS:
	#set(val):
		#if animation_tree:
			#animation_tree.set("parameters/conditions/Cancel", false)
			#animation_tree.set("parameters/conditions/PlayMotion", false)
			#ready_animation = ANIMATIONS.None
			#if val == ANIMATIONS.Swing:
				#animation_tree.set("parameters/conditions/Swing", true)
			#if val == ANIMATIONS.Stab:
				#animation_tree.set("parameters/conditions/Stab", true)

@export var animation_is_ready:bool

#@export var play_animation:bool:
	#set(val):
		#play_animation = false
		#animation_tree.set("parameters/conditions/Cancel", false)
		#animation_tree.set("parameters/conditions/PlayMotion", true)


@export var main_hand_sprite_sheet:Texture2D
@export var off_hand_sprite_sheet:Texture2D
@export var two_hand_sprite_sheet:Texture2D

#@export var animation:AnimationPlayer
@export var animation_tree:AnimationTree
@export var hand_sprite:Sprite2D
@export var weapon_node:ActorWeaponNode

@export var ready_animation_name:String = ''

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

func _ready() -> void:
	#animation.animation_finished.connect(on_animation_finished)
	animation_tree.animation_started.connect(on_animation_started)
	animation_tree.animation_finished.connect(on_animation_finished)

var should_be_playing:bool
func _process(delta: float) -> void:
	animation_tree.advance(delta * CombatRootControl.get_time_scale())
	#if should_be_playing:
		#if not animation_tree.get("parameters/conditions/PlayMotion"):
			#printerr("Bad Play")
			#animation_tree.set("parameters/conditions/PlayMotion", true)
		#else:
			#should_be_playing = false

func set_weapon(weapon:BaseWeaponEquipment):
	weapon_node.visible = true
	weapon_node.set_weapon(weapon)

func hide_weapon():
	weapon_node.visible = false

func ready_arnimation(name):
	#animation.speed_scale = 100# = CombatRootControl.get_time_scale()
	animation_tree.set("parameters/conditions/Cancel", false)
	animation_tree.set("parameters/conditions/PlayMotion", false)
	if name == "weapon_swing":
		animation_tree.set("parameters/conditions/Swing", true)
		current_animation = name
		
	#var animation_name = name + "/ready" + dir_sufix
	#if not animation.has_animation(animation_name):
		#printerr("No ActorHand animation found with name: %s" % [animation_name])
		#return
	#animation.play(animation_name)
	#current_animation = animation_name

func execute_animation():
	if not current_animation:
		printerr("ActorHandNode.execute_animation: Called with no current_animation.")
		return
	should_be_playing = true
	printerr("Set Motion")
	animation_tree.set("parameters/conditions/PlayMotion", true)
	printerr("HandAnimation Executing: Cancel:%s | PlayMotion: %s" % 
	[animation_tree.get("parameters/conditions/Cancel"), animation_tree.get("parameters/conditions/PlayMotion")])
	#if current_animation.contains("/ready_"):
		#current_animation = current_animation.replace("/ready_", "/motion_")
		#animation.play(current_animation)

func cancel_animation():
	animation_tree.set("parameters/conditions/Cancel", true)
	#if current_animation.contains("/ready_"):
		#current_animation = current_animation.replace("/ready_", "/cancel_")
		#animation.play(current_animation)

func clear_any_animations(dir_sufix):
	animation_tree.set("parameters/conditions/Cancel", true)
	#animation.play("weapon_facing/facing" + dir_sufix)

func on_animation_finished(animation_name):
	printerr("HandAnimation Finished: %s" % [animation_name])
	printerr("HandAnimation Finished: Cancel:%s | PlayMotion: %s" % 
	[animation_tree.get("parameters/conditions/Cancel"), animation_tree.get("parameters/conditions/PlayMotion")])

func on_animation_started(animation_name):
	#animation.speed_scale = 100
	printerr("HandAnimation Started: %s" % [animation_name])
	printerr("HandAnimation Started: Cancel:%s | PlayMotion: %s" % 
	[animation_tree.get("parameters/conditions/Cancel"), animation_tree.get("parameters/conditions/PlayMotion")])
	
	
	## Hold onto the "ready" animation since the actor is holding the pose
	#if finished.contains("/ready_"):
		#return
	#if current_animation == finished:
		#current_animation = null
	#else:
		#printerr("Hand Animation mismatch: Current: %s | Finshed: %s" % [current_animation, finished])


func set_facing_dir(dir):
	if dir == MapPos.Directions.North:
		if hand == HANDS.MainHand:
			hand_z_offset = 0
			weapon_z_offset = 0
			weapon_under_hand_z_offset = 1
			weapon_over_hand_z_offset = -1
		if hand == HANDS.OffHand:
			hand_z_offset = 1
			weapon_z_offset = 0
			weapon_under_hand_z_offset = 2
			weapon_over_hand_z_offset = 0
		if hand_sprite and hand_sprite.vframes == 4:
			hand_sprite.frame_coords.y = 1
		#animation.play("weapon_facing/facing_north")
	
	if dir == MapPos.Directions.East:
		if hand == HANDS.MainHand:
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
		#animation.play("weapon_facing/facing_east")
	
	if dir == MapPos.Directions.South:
		if hand == HANDS.MainHand:
			hand_z_offset = 0
			weapon_z_offset = 1
			weapon_under_hand_z_offset = -1
			weapon_over_hand_z_offset = 1
		if hand == HANDS.OffHand:
			hand_z_offset = 0
			weapon_z_offset = 1
			weapon_under_hand_z_offset = -1
			weapon_over_hand_z_offset = 1
		if hand_sprite and hand_sprite.vframes == 4:
			hand_sprite.frame_coords.y = 0
		#animation.play("weapon_facing/facing_south")
	
	if dir == MapPos.Directions.West:
		if hand == HANDS.MainHand:
			hand_z_offset = 0
			weapon_z_offset = 1
			weapon_under_hand_z_offset = -1
			weapon_over_hand_z_offset = 1
		if hand == HANDS.OffHand:
			hand_z_offset = 0
			weapon_z_offset = 1
			weapon_under_hand_z_offset = -1
			weapon_over_hand_z_offset = 1
		if hand_sprite and hand_sprite.vframes == 4:
			hand_sprite.frame_coords.y = 3
		#animation.play("weapon_facing/facing_west")
