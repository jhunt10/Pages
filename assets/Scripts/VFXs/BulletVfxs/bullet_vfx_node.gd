class_name BulletVfxNode
extends BaseAttackVfxNode

var starting_offset:Vector2i
var velocity:float
var damage_vfx_datas:Array = []
var rotation_offset:float
@export var sprite:Sprite2D

var frame_count = 0

func _on_start():
	var source_actor_id = _data.get("SourceActorId", '')
	if source_actor_id == '':
		printerr("BulletVfxNode: No Source ActorId")
		self.finish()
		return
	super()
	velocity = _data.get("Velocity", 300)
	
	# Load Sprite
	var sprite_name = _data.get("SpriteName")
	if sprite_name:
		var sprite_path = _data.get("LoadPath", "NO_LOAD_PATH").path_join(sprite_name)
		if ResourceLoader.exists(sprite_path):
			sprite.texture = load(sprite_path)
			sprite.hframes = _data.get("SpriteSheetWidth", 1)
			sprite.vframes = _data.get("SpriteSheetHight", 1)
		else:
			printerr("BaseSpriteVfxNode.set_vfx_data: Failed to find file '%s'." % [sprite_path])
			self.finish()
			return
	
	# Get source actor position
	var source_actor_node = CombatRootControl.get_actor_node(source_actor_id)
	starting_offset =  source_actor_node.global_position - self.global_position
	sprite.position = starting_offset
	var sprite_scale = _data.get('Scale', null)
	if sprite_scale:
		if sprite_scale is float or sprite_scale is int:
			sprite_scale = [sprite_scale,sprite_scale]
		sprite.scale = Vector2(sprite_scale[0], sprite_scale[1])
	rotation_offset = deg_to_rad(_data.get("Rotation", 0))
	sprite.rotation = rad_to_deg(source_actor_node.global_position.angle_to(self.global_position)) + rotation_offset


func _process(delta: float) -> void:
	frame_count += 1
	sprite.position = sprite.position.move_toward(Vector2.ZERO, delta * velocity)
	
	var angle = sprite.position.direction_to(Vector2.ZERO).angle() + (PI / 2)
	sprite.rotation = angle + rotation_offset
	if abs(sprite.position.distance_to(Vector2.ZERO)) < 0.01:
		self.finish()

func add_damage_effect(vfx_data:Dictionary):
	damage_vfx_datas.append(vfx_data)

func _on_delete():
	var actor = self.actor_node.Actor
	for damage_vfx_data in damage_vfx_datas:
		var vfx_key = damage_vfx_data['VfxKey']
		VfxHelper.create_damage_effect(actor, vfx_key, damage_vfx_data)

func finish():
	print("Missile was processed %s times" % [frame_count])
	super()
	
