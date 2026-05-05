class_name ThrowFlameVfxNode
extends BaseVfxNode
# Not a partical node since persistant 
# This is realy more like a beam since it last whole turn
# (but not really since it simply hits full area)
var particals_finished = false

func start_vfx():
	var dir = actor_node.facing_dir	
	if dir == 1: 
		self.rotation_degrees = 90
		self.position = Vector2(0, 8)
	if dir == 2: 
		self.rotation_degrees = 180
	if dir == 3: 
		self.rotation_degrees = 270
		self.position = Vector2(0, 8)
	var partical_node:CPUParticles2D = $CPUParticles2D
	partical_node.emitting = true
	partical_node.finished.connect(on_last_partical)
	actor_node.Actor.action_failed.connect(finish)


func finish():
	if _state == States.Finished:
		return
	var partical_node:CPUParticles2D = $CPUParticles2D
	partical_node.one_shot = true
	
	_state = States.Finished

func is_ready_to_delete()->bool:
	return particals_finished

func on_last_partical():
	particals_finished = true
	#_on_delete()
	#if vfx_holder and vfx_holder.has_vfx(self.id):
		#vfx_holder.remove_vfx(self.id)
	#finished.emit()
	
