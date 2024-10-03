class_name StatPanelControl
extends Control

@onready var health_bar:StatBarControl = $HealthStatBar
@onready var energy_bar:StatBarControl = $HealthStatBar
@onready var effect_icon_box:HBoxContainer = $IconBoxContainer

var actor:BaseActor
var effect_icons:Dictionary

func set_actor(act:BaseActor):
	if actor:
		printerr("Actor already set on StatPanel.")
		return
	actor = act
	CombatRootControl.Instance.QueController.end_of_frame.connect(sync)
	CombatRootControl.Instance.QueController.end_of_turn.connect(sync)
	CombatRootControl.Instance.QueController.end_of_round.connect(sync)
	_sync_values()
	
func sync():
	_sync_values()
	_sync_icons()

func _sync_values():
	if !actor:
		printerr("No actor found for stat bar")
		return
	var max_hp = actor.stats.max_health
	var cur_hp = actor.stats.current_health
	health_bar.set_values(cur_hp, max_hp)
	pass
	
func _sync_icons():
	for id in actor.effects._effects.keys():
		if effect_icons.has(id):
			continue
		var new_icon = TextureRect.new()
		new_icon.texture = actor.effects.get_effect(id).get_sprite()
		new_icon.visible = true
		effect_icon_box.add_child(new_icon)
		effect_icons[id] = new_icon
	for id in effect_icons.keys():
		if !actor.effects._effects.has(id):
			effect_icons[id].queue_free()
			effect_icons.erase(id)
