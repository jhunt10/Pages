class_name BaseAttackVfxNode
extends BaseVfxNode

func get_source_actor_id()->String:
	var source_actor_id = _data.get("SourceActorId", '')
	if source_actor_id == '':
		printerr("BaseAttackVfxNode: No Source ActorId")
		return ''
	return source_actor_id

func get_source_actor_node()->BaseActorNode:
	var source_actor_id = get_source_actor_id()
	if source_actor_id and source_actor_id != '':
		return CombatRootControl.get_actor_node(source_actor_id)
	return null
