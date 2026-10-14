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

var portraits:Array = []
var buttons:Array = []
var carried_actor_ids:Array = []
var is_sub_carrier:Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	portraits = [rogue_port, priest_port, mage_port]
	buttons = [rogue_button, priest_button, mage_button]
	rogue_button.pressed.connect(on_button.bind(0))
	priest_button.pressed.connect(on_button.bind(1))
	mage_button.pressed.connect(on_button.bind(2))
	pass # Replace with function body.

func set_carrier(carrier_actor:CarrierActor, pre_selected_actor_ids:Array):
	var carried_actors = carrier_actor.list_carried_actors()
	carried_actor_ids.clear()
	is_sub_carrier.clear()
	group_outline.hide()
	for carried_actor:BaseActor in carried_actors:
		carried_actor_ids.append(carried_actor.Id)
		is_sub_carrier.append(carried_actor is CarrierActor)
	
	for index in range(buttons.size()):
		var button:Button = buttons[index]
		var port:TextureRect = portraits[index]
		if index >= carried_actors.size():
			port.visible = false
			button.button_pressed = false
			button.disabled = true
		else:
			var carried_actor:BaseActor = carried_actors[index]
			var title = carried_actor.get_title_page()
			if title:
				port.texture = title.get_small_icon()
			else:
				port.texture = carried_actor.get_small_icon()
			port.visible = true
			button.disabled = false
			if pre_selected_actor_ids.has(carried_actor.Id):
				button.button_pressed = true
				if is_sub_carrier[index]:
					group_outline.show()
			else:
				button.button_pressed = false

func on_button(index:int):
	if index >= carried_actor_ids.size():
		return
	var button:Button = buttons[index]
	var any_sub_carrier_pressed = false
	for sub_carry_index in range(is_sub_carrier.size()):
		if is_sub_carrier[sub_carry_index] and buttons[sub_carry_index].button_pressed:
			any_sub_carrier_pressed = true
			break
	if any_sub_carrier_pressed:
		group_outline.show()
	else:
		group_outline.hide()
		var un_press_other_buttons = false
		if is_sub_carrier[index]: # Carrier Actor Un-Pressed
			un_press_other_buttons = true
		elif button.button_pressed: # Non-Carrier Pressed
			un_press_other_buttons = true
		if un_press_other_buttons:
			for sub_index in range(buttons.size()): # Un-Press all other buttons
				if sub_index != index:
					buttons[sub_index].button_pressed = false
	
	button_states_changed.emit(get_select_deploy_actor_ids())

func get_select_deploy_actor_ids()->Array:
	var out_list = []
	var carrier_actor_id = ""
	for index in range(carried_actor_ids.size()):
		var actor_id = carried_actor_ids[index]
		var is_pressed = buttons[index].button_pressed
		if is_pressed:
			out_list.append(actor_id)
		if is_sub_carrier[index]:
			carrier_actor_id = actor_id
	if carrier_actor_id:
		out_list.erase(carrier_actor_id)
		out_list.push_front(carrier_actor_id)
	return out_list
