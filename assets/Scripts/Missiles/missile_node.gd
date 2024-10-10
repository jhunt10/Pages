class_name MissileNode
extends Node2D

@onready var missile_sprie:Sprite2D = $MissileSprie
@onready var animation:AnimationPlayer = $AnimationPlayer

var missile:BaseMissile

func _ready() -> void:
	if missile:
		var anidata = missile.get_missile_animation_data()
		if anidata:
			anidata.set_sprite_and_animation(missile_sprie, animation)

func set_missile_data(missle):
	missile = missle
	missile.node = self
	var h_frames = null

func sync_pos():
	var current_frame = CombatRootControl.Instance.QueController.sub_action_index
	var pos = missile.get_position_for_frame(current_frame)
	if pos:
		self.position = pos
		
	var start_pos:Vector2 = missile._position_per_frame[0]
	var end_pos:Vector2 = missile._position_per_frame[missile._position_per_frame.size() -1]
	var angle = start_pos.direction_to(end_pos).angle() + (PI / 2)
	missile_sprie.rotation = angle

func on_missile_reach_target():
	missile.on_reach_target()
	self.queue_free()
