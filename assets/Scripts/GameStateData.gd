class_name GameStateData
# This class holds a state of the game. This involes all information about the map,
# actors, effects, and thier statues.

# Dictionary of Actor.Id to Actor
var Actors:Dictionary = {}
var Missiles:Dictionary = {}
var Zones:Dictionary = {}

# Current state of the map
var MapState:MapStateData

func add_actor(actor:BaseActor):
	Actors[actor.Id] = actor

func kill_actor(actor:BaseActor):
	actor.on_death()
	
func add_missile(missile:BaseMissile):
	Missiles[missile.Id] = missile

func delete_missile(missile:BaseMissile):
	Missiles.erase(missile.Id)

func add_zone(zone:BaseZone):
	Zones[zone.Id] = zone
	MapState.add_zone(zone)
