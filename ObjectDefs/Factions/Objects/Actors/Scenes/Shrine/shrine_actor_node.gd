class_name ShrineActorNode
extends BaseActorNode

func _ready() -> void:
	super()
	body_animation.animation_finished.connect(_on_animation_finish)

func start_spawning_animation():
	body_animation.play("flash")

func play_actor_spawn_animation():
	if Actor is SpawnerActor:
		Actor._spawn_actor()

func _on_animation_finish(name):
	if name == "flash":
		Actor.spawn_finished.emit()
