class_name ParticleSpriteVfxNode
extends BaseVfxNode

@export var gpu_partical_node:GPUParticles2D
@export var audio_stream:AudioStreamPlayer2D
## Triggers chained Vfxs after this delay (Because particals_finished is late)
@export var fake_life_time:float = 0.5
var particals_finished = false
var audio_finished = false
var timer = 0

func _process(_delta: float) -> void:
	super(_delta)
	if timer > 0:
		timer -= _delta
		if timer <= 0 and not _built_chained_vfxs:
			build_chained_vfx()

func set_vfx_data(new_id:String, data:Dictionary):
	super(new_id, data)
	if _data.get("MatchSourceDir", false):
		var source_actor_node = CombatRootControl.get_actor_node(_data.get("SourceActorId", ""))
		if source_actor_node:
			var dir = source_actor_node.facing_dir
			if dir == 1: gpu_partical_node.rotation_degrees = 90
			if dir == 2: 
				gpu_partical_node.rotation_degrees = 180
				gpu_partical_node.scale = Vector2(1,1)
			if dir == 3: 
				#gpu_partical_node.rotation_degrees = 270
				gpu_partical_node.scale = Vector2(-1,1)

func start_vfx():
	super()
	timer = fake_life_time
	gpu_partical_node.emitting = true
	gpu_partical_node.finished.connect(on_last_partical)
	
	if vfx_holder:
		if not actor_node:
			printerr("ParticleSpriteVfxNode: vfx_holder.actor_node is null")
			return
		var sprite_bounds = actor_node.actor_sprite.get_sprite_bounds()
			
		if gpu_partical_node:
			var sprite_area = Vector2i(sprite_bounds.size.x / 2, sprite_bounds.size.y / 2)
			gpu_partical_node.process_material.emission_box_extents = Vector3(sprite_area.x, sprite_area.y, 0)
		
	if audio_stream and audio_stream.stream != null:
		audio_stream.play()
		audio_stream.finished.connect(on_audio_finish)
	else:
		audio_finished = true
	
	_trigger_next_vfxs()

func is_ready_to_delete()->bool:
	return particals_finished and audio_finished

func on_last_partical():
	particals_finished = true
	if audio_finished and _state != States.Finished:
		self.finish()

func on_audio_finish():
	audio_finished = true
	if particals_finished and _state != States.Finished:
		self.finish()
