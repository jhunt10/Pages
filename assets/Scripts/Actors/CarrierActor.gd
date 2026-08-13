class_name CarrierActor
extends BaseActor

signal  carried_actors_changed

var _held_actors:Dictionary = {}

# Lowest Priority is favored
func get_carrier_priority()->int:
	return actor_data.get("CarryPriority", 999)

func list_carried_actor_ids()->Array:
	return _held_actors.keys()

func list_carried_actors()->Array:
	return _held_actors.values()

func is_carrying_actor(actor):
	if actor is BaseActor:
		return _held_actors.keys().has(actor.Id)
	if actor is String:
		return _held_actors.keys().has(actor)
	return false

func add_carried_actor(actor, supress_change:bool=false):
	if actor is String:
		actor = ActorLibrary.get_actor(actor)
	if _held_actors.keys().has(actor.Id):
		return # Already Added
	if actor is CarrierActor:
		for sub_child in actor.list_carried_actors():
			actor.remove_held_actor(sub_child, true)
			self.add_carried_actor(sub_child, true)
		actor.sprite._build_sprite_sheet()
		actor.stats.recache_stats()
		actor.page_list_changed.emit()
	
	_held_actors[actor.Id] = actor
	actor.parent_carrier_actor_id = self.Id
	actor.page_list_changed.connect(self.page_list_changed.emit)
	if not supress_change:
		sprite._build_sprite_sheet()
		stats.recache_stats()
		self.page_list_changed.emit()
		carried_actors_changed.emit()

func remove_held_actor(actor, supress_change:bool=false):
	if actor is String:
		actor = ActorLibrary.get_actor(actor)
	if not _held_actors.keys().has(actor.Id):
		return # Already Added
	_held_actors.erase(actor.Id)
	actor.page_list_changed.disconnect(self.page_list_changed.emit)
	if actor.parent_carrier_actor_id == self.Id:
		actor.parent_carrier_actor_id = null
	if not supress_change:
		sprite._build_sprite_sheet()
		stats.recache_stats()
		self.page_list_changed.emit()
		carried_actors_changed.emit()
	

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
