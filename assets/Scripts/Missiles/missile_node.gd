class_name MissileNode
extends Node2D

#@onready var missile_sprie:Sprite2D = $MissileSprie
#@onready var animation:AnimationPlayer = $AnimationPlayer

var missile:BaseMissile
var missile_effect_node:BaseVfxNode
var impact_effect_node:BaseVfxNode

func _ready() -> void:
	if missile_effect_node:
		missile_effect_node.start_vfx()
	pass
	#if missile:
		#var anidata = missile.get_missile_animation_data()
		#if anidata:
			#anidata.set_sprite_and_animation(missile_sprie, animation)

func set_missile_data(missle):
	self.missile = missle
	self.name = missile._missle_data.get("DisplayName", "Missile") +  "_" + missile.Id
	missile.node = self
	var vfx_data = missile.get_missile_vfx_data()
	if not vfx_data:
		printerr("missile_node: No Missile Vfx Data found")
		return
	missile_effect_node = VfxHelper.create_missile_vfx_node(vfx_data.get("VfxKey", ""), vfx_data)
	self.add_child(missile_effect_node)

func _process(delta: float) -> void:
	var cur_target_pos = missile.get_current_moveto_position()
	var new_pos = self.position.move_toward(cur_target_pos, delta * missile._real_velocity)
	self.position = new_pos
	pass

func sync_pos():
	if missile.has_reached_target():
		self.position = missile.get_final_position()
		return
		
	var current_frame = CombatRootControl.Instance.QueController.sub_action_index
	var pos = missile.get_position_for_frame(current_frame)
	if pos:
		self.position = pos
	
	if missile._position_per_frame.size() > 0:
		var start_pos:Vector2 = missile._position_per_frame[0]
		var end_pos:Vector2 = missile._position_per_frame[missile._position_per_frame.size() -1]
		if missile_effect_node:
			var angle = start_pos.direction_to(end_pos).angle() + (PI / 2)
			missile_effect_node.rotation = angle

func on_missile_reach_target():
	var delete_self = true
	if missile.has_impact_vfx():
		self.position = missile.get_final_position()
		var impact_data = missile.get_impact_vfx_data()
		if impact_data.size() > 0:
			impact_effect_node = VfxHelper.create_missile_vfx_node(impact_data.get("VfxKey", ""), impact_data)
			if not impact_effect_node:
				printerr("Failed to find impact effect for missile: %s" + missile.Id)
			else:
				impact_effect_node.finished.connect(_on_impact_effect_finished)
				self.add_child(impact_effect_node)
				delete_self = false
	if missile_effect_node is MissileVfxNode:
		missile_effect_node.animation.play("fade_out")
		missile_effect_node.animation.animation_finished.connect(_on_impact_effect_finished)
	#if delete_self:
		#self.queue_free()

func _on_impact_effect_finished():
	self.queue_free()
