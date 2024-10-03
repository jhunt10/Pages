class_name MapSpot

var parent_map:MapStateData = null
var X:int = 0
var Y:int = 0
var terrain_index:int = 0

var _actor_ids:Array=[]
var _zone_ids:Array = []

func _init(x:int, y:int, terrain_index:int, parent:MapStateData) -> void:
	parent_map = parent
	X = x
	Y = y
	self.terrain_index = terrain_index
	
func add_actor(actor:BaseActor):
	if _actor_ids.has(actor.Id):
		printerr("Actor " + actor.Id + " is already set for spot (" + str(X) + "," + str(Y) + ")")
	else:
		_actor_ids.append(actor.Id)

func remove_actor(actor:BaseActor):
	if _actor_ids.has(actor.Id):
		_actor_ids.erase(actor.Id)
		
func get_actors()->Array:
	var out = []
	for id in _actor_ids:
		out.append(parent_map._game_state.Actors[id])
	return out

func add_zone(zone:BaseZone):
	if _zone_ids.has(zone.Id):
		return
	_zone_ids.append(zone.Id)

func remove_zone(zone:BaseZone):
	if _zone_ids.has(zone.Id):
		_zone_ids.erase(zone.Id)

func get_zones()->Array:
	var out_list = []
	for z in _zone_ids:
		out_list.append(parent_map._game_state.Zones[z])
	return out_list
		
