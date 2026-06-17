class_name CarrierActor
extends BaseActor

var _held_actors:Dictionary = {}

func list_held_actor_ids()->Array:
	return _held_actors.keys()

func list_held_actors()->Array:
	return _held_actors.values()

func is_holding_actor(actor:BaseActor):
	return _held_actors.keys().has(actor.Id)

func add_held_actor(actor:BaseActor):
	if _held_actors.keys().has(actor.Id):
		return # Already Added
	_held_actors[actor.Id] = actor
	actor.parent_carrier_actor_id = self.Id
	actor.page_list_changed.connect(self.page_list_changed.emit)
	sprite._build_sprite_sheet()
	stats.recache_stats()
	self.page_list_changed.emit()

func remove_held_actor(actor:BaseActor):
	if not _held_actors.keys().has(actor.Id):
		return # Already Added
	_held_actors.erase(actor.Id)
	actor.page_list_changed.disconnect(self.page_list_changed.emit)
	if actor.parent_carrier_actor_id == self.Id:
		actor.parent_carrier_actor_id = null
	sprite._build_sprite_sheet()
	stats.recache_stats()
	self.page_list_changed.emit()
	

# Used by Que Input Control
func get_action_list()->Array:
	var list = super()
	for child:BaseActor in _held_actors.values():
		for sub_action in child.get_action_list():
			if not list.has(sub_action):
				list.append(sub_action)
	return list

func get_action_key_list()->Array:
	var list = super()
	for child:BaseActor in _held_actors.values():
		for sub_key in child.get_action_key_list():
			if not list.has(sub_key):
				list.append(sub_key)
	return list


func fill_page_ammo(action_id:String=''):
	super(action_id)
	for child:BaseActor in _held_actors.values():
		child.pages.fill_page_ammo(action_id)
