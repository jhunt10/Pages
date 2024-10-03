class_name MissileNode
extends Node2D

@onready var missile_sprie:Sprite2D = $MissileSprie

var missile_data:BaseMissile

func set_missile_data(data:BaseMissile):
	missile_data = data
	missile_data.node = self

func sync_pos():
	var current_frame = CombatRootControl.Instance.QueController.sub_action_index
	var pos = missile_data.get_position_for_frame(current_frame)
	if pos:
		self.position = pos
		
	var start_pos:Vector2 = missile_data._position_per_frame[0]
	var end_pos:Vector2 = missile_data._position_per_frame[missile_data._position_per_frame.size() -1]
	var angle = start_pos.direction_to(end_pos).angle()
	missile_sprie.rotation = angle

func on_missile_reach_target():
	missile_data.on_reach_target()
	self.queue_free()
