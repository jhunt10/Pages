@tool
class_name ShrineActorNode
extends ObjectActorNode

func start_spawning_animation():
	body_animation.play("flash")
	if not body_animation.animation_finished.is_connected(_on_animation_finish):
		body_animation.animation_finished.connect(_on_animation_finish)

func play_actor_spawn_animation():
	if Actor is SpawnerActor:
		Actor._spawn_actor()

func _on_animation_finish(animation_name):
	if animation_name == "flash":
		Actor.spawn_finished.emit()
