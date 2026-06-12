@tool
class_name BlockEvadeStatEntry
extends Control

@export var show_block:bool:
	set(val):
		show_block = val
		if show_block and block_row:
			block_row.show()
			self.size = Vector2(self.size.x, 80)
		elif block_row:
			block_row.hide()
			self.size = Vector2(self.size.x, 61)
			
@export var block_row:Container
@export var evade_front_label:Label
@export var evade_flank_label:Label
@export var evade_back_label:Label
@export var block_front_label:Label
@export var block_flank_label:Label
@export var block_back_label:Label
@export var awareness_value_label:Label
@export var awareness_display:MiniAwarenessDisplay

func set_actor(actor:BaseActor):
	var awareness = actor.stats.get_stat("Awareness", 0)
	awareness_value_label.text = str(awareness)
	awareness_display.awareness = 0
	
	var evade_value = actor.stats.get_stat("Evasion", 0)
	printerr("Evastion: " + str(evade_value))
	var block_value = actor.stats.get_stat("BlockChance", -1)
	if block_value < 0:
		block_value = "--"
		show_block = false
	else:
		show_block = true
	evade_value = (1- DamageHelper.calc_armor_reduction(evade_value)) * 100
	printerr("EvastionChance: " + str(evade_value))
	if evade_value < 10:
		evade_value = ("%2.1f" % [evade_value]) + "%"
	else:
		evade_value = ("%1.0f" % [evade_value]) + "%"
	
	evade_front_label.text = str(evade_value)
	block_front_label.text = str(block_value) + "%"
	
	evade_flank_label.text = str(evade_value)
	block_flank_label.text = str(block_value) + "%"
	
	evade_back_label.text = str(evade_value)
	block_back_label.text = str(block_value) + "%"
