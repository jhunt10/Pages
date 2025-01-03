class_name CampMenu
extends Control

@export var camp_options_container:CampOptionsContainer
@export var system_options_container:CampOptionsContainer

@export var quest_button:CampOptionButton
@export var shop_button:CampOptionButton
@export var character_button:CampOptionButton
@export var explort_button:CampOptionButton
@export var system_button:CampOptionButton

@export var sys_back_button:CampOptionButton
@export var sys_save_button:CampOptionButton
@export var sys_load_button:CampOptionButton
@export var sys_debug_button:CampOptionButton
@export var sys_quit_button:CampOptionButton

@export var no_shop_pop_up:NoShopPopUp

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	no_shop_pop_up.hide()
	character_button.button.pressed.connect(_on_prepare_button)
	quest_button.button.pressed.connect(_on_quest_button)
	shop_button.button.pressed.connect(no_shop_pop_up.do_thing)
	explort_button.button.pressed.connect(_on_explore_button)
	system_button.button.pressed.connect(_sub_menu_open.bind("System"))
	sys_back_button.button.pressed.connect(_sub_menu_open.bind("Main"))
	sys_save_button.button.pressed.connect(_on_save_button)
	sys_load_button.button.pressed.connect(_on_load_button)
	sys_debug_button.button.pressed.connect(_on_debug_button)
	sys_quit_button.button.pressed.connect(_on_quit)
	
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
	#MainRootNode.Instance.start_combat()
	pass

func _on_explore_button():
	MainRootNode.Instance.open_map_selection_menu()

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

func _on_quit():
	MainRootNode.Instance.go_to_main_menu()
