class_name CarrierActor
extends BaseActor

signal  carried_actors_changed

var _held_actors:Dictionary = {}

# Virtutal func to get tags specific to Object class
func _get_object_specific_tags()->Array:
	var out_list = super()
	if not out_list.has("Carrier"):
		out_list.append("Carrier")
	return out_list

# Lowest Priority is favored
func get_carrier_priority()->int:
	return actor_data.get("CarryPriority", 999)

func list_carried_actor_ids(order_by_party_index:bool=false)->Array:
	var actor_ids = _held_actors.keys()
	if is_player and order_by_party_index:
		actor_ids.sort()
	return actor_ids

func list_carried_actors(order_by_party_index:bool=false)->Array:
	if is_player and order_by_party_index:
		var out_list = []
		var actor_ids = _held_actors.keys()
		actor_ids.sort()
		for actor_id in actor_ids:
			out_list.append(_held_actors[actor_id])
		return out_list
	return _held_actors.values()

func is_carrying_actor(actor):
	if actor is BaseActor:
		return _held_actors.keys().has(actor.Id)
	if actor is String:
		return _held_actors.keys().has(actor)
	return false

func add_carried_actor(actor, supress_change:bool=false):
	var adding_actor:BaseActor
	if actor is String:
		adding_actor = ActorLibrary.get_actor(actor)
	if actor is BaseActor:
		adding_actor = actor
	if !actor:
		return
	
	if _held_actors.keys().has(adding_actor.Id):
		return # Already Added
	
	if adding_actor is CarrierActor:
		for sub_child in adding_actor.list_carried_actors():
			adding_actor.remove_held_actor(sub_child, true)
			self.add_carried_actor(sub_child, true)
		adding_actor.sprite._build_sprite_sheet()
		adding_actor.stats.recache_stats()
		adding_actor.page_list_changed.emit()
	
	if adding_actor.is_being_carried():
		var other_carrier = adding_actor.get_carrier_actor()
		other_carrier.remove_held_actor(adding_actor)
	
	_held_actors[adding_actor.Id] = adding_actor
	adding_actor.parent_carrier_actor_id = self.Id
	adding_actor.page_list_changed.connect(self.page_list_changed.emit)
	if not supress_change:
		sprite._build_sprite_sheet()
		stats.recache_stats()
		self.page_list_changed.emit()
		carried_actors_changed.emit()
		self.Que.action_que_changed.emit()

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

func fill_page_ammo(action_id:String=''):
	super(action_id)
	for child:BaseActor in _held_actors.values():
		child.pages.fill_page_ammo(action_id)
