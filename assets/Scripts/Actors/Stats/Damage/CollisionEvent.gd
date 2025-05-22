class_name CollisionEvent

var moving_actor_id:String
var blocking_actor_id:String
var damage_event:DamageEvent
var attack_mods:Dictionary
var winner_id:String

func _init(moving_actor:BaseActor, blocking_actor:BaseActor, winning_actor:BaseActor, damage_event:DamageEvent, atk_mods:Dictionary) -> void:
	moving_actor_id = moving_actor.Id
	blocking_actor_id = blocking_actor.Id
	self.damage_event = damage_event
	attack_mods = atk_mods
	winner_id = winning_actor.Id
