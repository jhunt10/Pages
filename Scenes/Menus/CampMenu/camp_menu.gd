class_name CampMenu
extends Control

@export var camp_options_container:CampOptionsContainer
@export var system_options_container:CampOptionsContainer

@export var quest_button:CampOptionButton
@export var character_button:CampOptionButton
@export var system_button:CampOptionButton

@export var sys_back_button:CampOptionButton
@export var sys_save_button:CampOptionButton
@export var sys_load_button:CampOptionButton
@export var sys_debug_button:CampOptionButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	character_button.button.pressed.connect(_on_prepare_button)
	quest_button.button.pressed.connect(_on_quest_button)
	system_button.button.pressed.connect(_sub_menu_open.bind("System"))
	sys_back_button.button.pressed.connect(_sub_menu_open.bind("Main"))
	sys_save_button.button.pressed.connect(_on_save_button)
	sys_load_button.button.pressed.connect(_on_load_button)
	sys_debug_button.button.pressed.connect(_on_debug_button)
	
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

func _on_quest_button():
	MainRootNode.Instance.start_combat()

func _on_prepare_button():
	var actor = StoryState.get_player_actor()
	if actor:
		MainRootNode.Instance.open_character_sheet(actor)

func _on_save_button():
	MainRootNode.Instance.open_save_menu()
	_sub_menu_open("Main")
	pass

func _on_load_button():
	MainRootNode.Instance.open_load_menu()
	_sub_menu_open("Main")
	pass

func _on_debug_button():
	MainRootNode.Instance.open_dev_tools()
