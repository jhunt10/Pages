class_name SmokeVfxNode
extends BaseVfxNode

@export var particles:CPUParticles2D
@export var timer:float

var actor:BaseActorNode



func _on_start(): 
	particles.emitting = true

func _process(delta: float) -> void:
	if timer > 0:
		timer -= delta
		if timer < 0:
			if actor: actor.visible = !actor.visible
	if not particles.emitting:
		self.finish()
