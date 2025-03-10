class_name LightningChainVfxNode
extends BaseVfxNode

@export var animation_player:AnimationPlayer

var target_actor_id:String
var target_actor_node:ActorNode

func _on_start():
	target_actor_id = _data.get("TargetActorId", '')
	if target_actor_id == '':
		printerr("Chain Lightning Effect: No Target ActorId")
		self.finish()
	else:
		target_actor_node = CombatRootControl.get_actor_node(target_actor_id)
		animation_player.play("animation")
		animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(animation_name:String):
	self.finish()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if vfx_holder and _state == States.Playing:
		var actor_node = vfx_holder.actor_node
		var rot = actor_node.get_angle_to(target_actor_node.position)
		self.rotation = rot
	pass

func _on_delete():
	super()
	
