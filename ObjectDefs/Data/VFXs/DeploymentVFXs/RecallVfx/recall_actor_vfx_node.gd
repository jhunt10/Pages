class_name RecallActorVfxNode
extends BaseVfxNode

@export var sprite_motion_node:Node2D
@export var sprite_offset_node:Node2D
@export var sprite:Sprite2D
@export var particals:CPUParticles2D

var starting_offset:Vector2i
var velocity:float
var damage_vfx_datas:Array = []
var rotation_offset:float
var target_position:Vector2i
var particals_finished=false
var source_actor_node:BaseActorNode
var time_to_shrink:float = 0.5
var shrink_timer:float = 0.0
var done_srinking:bool = false

var frame_count = 0

func _on_start():
	if source_actor_id == '':
		printerr("BulletVfxNode: No Source ActorId")
		self.finish()
		return
	super()
	
	# Get source actor position
	source_actor_node = CombatRootControl.get_actor_node(source_actor_id)
	starting_offset =  source_actor_node.global_position - self.global_position
	sprite_motion_node.position = starting_offset
	self.modulate = StoryState.get_player_color(source_actor_node.Actor)
	
	target_position = vfx_holder.position * -1
	var distance = starting_offset.distance_to(target_position)
	velocity = distance*1.5
	particals.finished.connect(_on_last_partical)
	
	shrink_timer = time_to_shrink
	sprite.scale = Vector2(0,0)

func _process(delta: float) -> void:
	super(delta)
	frame_count += 1
	if shrink_timer > 0:
		shrink_timer -= delta
		var per = max(0,shrink_timer / time_to_shrink)
		source_actor_node.actor_motion_node.scale = Vector2(per,per)
		sprite.scale = Vector2(1-per,1-per)
	else:
		sprite_motion_node.position = sprite_motion_node.position.move_toward(target_position, delta * velocity)
		
		#var full_dist = starting_offset.distance_to(target_position)
		#var rel_dist = starting_offset.distance_to(sprite_motion_node.position)
		#sprite_offset_node.position.y = 0 - (rel_dist - ((rel_dist * rel_dist) / full_dist))
		
		if starting_offset.x < target_position.x:
			sprite_offset_node.rotation_degrees = sprite_offset_node.rotation_degrees + 10
		else:
			sprite_offset_node.rotation_degrees = sprite_offset_node.rotation_degrees - 10
		 
		if abs(sprite_motion_node.position.distance_to(target_position)) < 0.01:
			if not self._state == States.Finished:
				self.finish()

func is_ready_to_delete()->bool:
	if not particals_finished:
		return false
	return true

func finish():
	print("Bullet was processed %s times" % [frame_count])
	super()
	particals.emitting = false
	sprite.hide()
	var source_actor_node = CombatRootControl.get_actor_node(source_actor_id)
	source_actor_node.actor_motion_node.scale = Vector2.ONE

func _on_last_partical():
	particals_finished = true
	if _state != States.Finished:
		self.finish()

func _on_actor_animation_finished(_animation_name):
	sprite_motion_node.show()
