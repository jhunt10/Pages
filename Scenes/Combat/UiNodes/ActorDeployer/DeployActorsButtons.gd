class_name DeployActorButtons
extends Control

signal button_states_changed(values:Array)

@export var group_outline:NinePatchRect
@export var rogue_port:TextureRect
@export var rogue_button:Button
@export var priest_port:TextureRect
@export var priest_button:Button
@export var mage_port:TextureRect
@export var mage_button:Button

var button_states = [0,0,0]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rogue_button.pressed.connect(on_button.bind(0))
	priest_button.pressed.connect(on_button.bind(1))
	mage_button.pressed.connect(on_button.bind(2))
	pass # Replace with function body.

func set_carrier(carrier_actor:CarrierActor):
	var party_ids = StoryState.list_party_actors_ids()
	var held_actors = carrier_actor.list_carried_actor_ids()
	var has_rogue = held_actors.has(party_ids[1])
	var has_priest = held_actors.has(party_ids[2])
	var has_mage = held_actors.has(party_ids[3])
	
	rogue_button.disabled = not has_rogue
	rogue_button.visible = true
	rogue_port.visible = has_rogue
	priest_button.disabled = not has_priest
	priest_port.visible = has_priest
	mage_button.disabled = not has_mage
	mage_port.visible = has_mage
	clear_buttons()

func clear_buttons():
	group_outline.hide()
	rogue_button.button_pressed = false
	priest_button.button_pressed = false
	mage_button.button_pressed = false 

func on_button(index:int):
	if index == 1: # Priest
		if priest_button.button_pressed:
			group_outline.show()
		else:
			group_outline.hide()
			if rogue_button.button_pressed and mage_button.button_pressed:
				rogue_button.button_pressed = false
				mage_button.button_pressed = false 
	elif index == 0: # Rogue
		if rogue_button.button_pressed and not priest_button.button_pressed:
			mage_button.button_pressed = false
	elif index == 2: # Mage
		if mage_button.button_pressed and not priest_button.button_pressed:
			rogue_button.button_pressed = false
	button_states_changed.emit([
		rogue_button.button_pressed,
		priest_button.button_pressed,
		mage_button.button_pressed
	])

func get_select_deploy_actor_id()->String:
	var party_ids = StoryState.list_party_actors_ids()
	if priest_button.button_pressed:
		return party_ids[2]
	if rogue_button.button_pressed:
		return party_ids[1]
	if mage_button.button_pressed:
		return party_ids[3]
	return ""

func get_select_transfer_actor_ids()->Array:
	var out_list = []
	var party_ids = StoryState.list_party_actors_ids()
	if priest_button.button_pressed:
		if rogue_button.button_pressed:
			out_list.append(party_ids[1])
		if mage_button.button_pressed:
			out_list.append(party_ids[3])
	return out_list
