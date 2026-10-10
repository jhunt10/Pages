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


func on_button(index:int):
	if index == 1: # Priest
		if priest_button.button_pressed:
			group_outline.show()
		else:
			group_outline.hide()
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
