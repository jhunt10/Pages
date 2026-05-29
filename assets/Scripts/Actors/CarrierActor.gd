class_name CarrierActor
extends BaseActor

var _held_actors:Dictionary = {}

func list_held_actors()->Array:
	return _held_actors.values()

func add_held_actor(actor:BaseActor):
	if _held_actors.keys().has(actor.Id):
		return # Already Added
	_held_actors[actor.Id] = actor
	actor.parent_carrier_actor_id = self.Id

func remove_held_actor(actor:BaseActor):
	if not _held_actors.keys().has(actor.Id):
		return # Already Added
	_held_actors.erase(actor.Id)
	if actor.parent_carrier_actor_id == self.Id:
		actor.parent_carrier_actor_id = null
	

func get_action_key_list()->Array:
	var list = super()
	for child:BaseActor in _held_actors.values():
		for sub_key in child.get_action_key_list():
			if not list.has(sub_key):
				list.append(sub_key)
	return list
