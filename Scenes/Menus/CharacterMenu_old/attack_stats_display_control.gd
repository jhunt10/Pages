class_name AttackStatsDisplayControl
extends Control

@export var accuracy:StatLabelContainer
@export var evasion:StatLabelContainer
@export var potency:StatLabelContainer
@export var protection:StatLabelContainer

@export var crit_mod_label:Label
@export var crit_chance_label:Label

func set_actor(actor:BaseActor):
	accuracy.set_stat_values(actor)
	evasion.set_stat_values(actor)
	potency.set_stat_values(actor)
	crit_chance_label.text = str(actor.stats.get_stat("CritChance", 0)) + "%"
	crit_mod_label.text = str(actor.stats.get_stat("CritMod", 0) * 100) + "%"
