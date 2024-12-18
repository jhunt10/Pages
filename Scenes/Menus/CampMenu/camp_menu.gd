class_name CampMenu
extends Control

@export var camp_options_container:CampOptionsContainer
@export var system_options_container:CampOptionsContainer

@export var quest_button:CampOptionButton
@export var character_button:CampOptionButton
@export var system_button:CampOptionButton

@export var sys_back_button:CampOptionButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	character_button.button.pressed.connect(_on_prepare_button)
	system_button.button.pressed.connect(_sub_menu_open.bind("System"))
	sys_back_button.button.pressed.connect(_sub_menu_open.bind("Main"))
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

func _on_prepare_button():
	var actor = StoryState.get_player_actor()
	if actor:
		MainRootNode.Instance.open_character_sheet(actor)
