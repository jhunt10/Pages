class_name AuraHolder
extends Node2D

var _actor:BaseActor

func add_aura(zone_node:ZoneNode):
	self.add_child(zone_node)
