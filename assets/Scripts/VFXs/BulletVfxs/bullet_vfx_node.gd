class_name BulletVfxNode
extends BaseSpriteVfxNode

var starting_offset:Vector2i
var velocity:float
var damage_vfx_datas:Array = []

func _on_start():
	var source_actor_id = _data.get("SourceActorId", '')
	if source_actor_id == '':
		printerr("BulletVfxNode: No Source ActorId")
		self.finish()
		return
	super()
	velocity = _data.get("Velocity", 300)
	var source_actor_node = CombatRootControl.get_actor_node(source_actor_id)
	var source_actor_node_pos = source_actor_node.global_position
	var self_pos = self.global_position
	starting_offset =  source_actor_node.global_position - self.global_position
	sprite.position = starting_offset
	sprite.rotation_degrees = source_actor_node.global_position.angle_to(self.global_position)

func _process(delta: float) -> void:
	sprite.position = sprite.position.move_toward(Vector2.ZERO, delta * velocity)
	
	var angle = sprite.position.direction_to(Vector2.ZERO).angle() + (PI / 2)
	sprite.rotation = angle
	if abs(sprite.position.distance_to(Vector2.ZERO)) < 0.01:
		self.finish()

func add_damage_effect(vfx_data:Dictionary):
	damage_vfx_datas.append(vfx_data)

func _on_delete():
	var actor = self.actor_node.Actor
	for damage_vfx_data in damage_vfx_datas:
		var vfx_key = damage_vfx_data['VfxKey']
		VfxHelper.create_damage_effect(actor, vfx_key, damage_vfx_data)
