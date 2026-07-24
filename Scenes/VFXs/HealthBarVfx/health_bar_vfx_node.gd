class_name HealthBarVfx
extends BaseVfxNode


@export var label:Label

func _on_start(): 
	var actor = self.actor_node.Actor
	actor.health_changed.connect(sync)
	sync()

func _on_delete():
	var actor = self.actor_node.Actor
	if actor and actor.health_changed.is_connected(sync):
		actor.health_changed.disconnect(sync)

func sync():
	var actor = self.actor_node.Actor
	var max_health = actor.stats.max_health
	var current_health = actor.stats.current_health
	label.text = str(int(current_health)) + "/" + str(int(max_health)) 
