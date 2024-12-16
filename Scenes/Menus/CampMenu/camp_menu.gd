class_name CampMenu
extends Control

@export var camp_options_container:CampOptionsContainer
@export var system_options_container:CampOptionsContainer

@export var quest_button:Button
@export var character_button:Button
@export var system_button:Button

@export var sys_back_button:Button
@export var sys_settings_button:Button
@export var sys_load_button:Button
@export var sys_save_button:Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	system_button.pressed.connect(_sub_menu_open.bind("System"))
	sys_back_button.pressed.connect(_sub_menu_open.bind("Main"))
	_sub_menu_open("Main")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _sub_menu_open(name:String):
	if name == "System":
		camp_options_container.hide()
		system_options_container.show()
		system_options_container.resize_options = true
	else:
		camp_options_container.show()
		system_options_container.hide()
