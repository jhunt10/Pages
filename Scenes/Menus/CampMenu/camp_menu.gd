class_name CampMenu
extends Control

static var Instance:CampMenu

@export var dialog_control:DialogController
@export var camp_options_container:CampOptionsContainer
@export var system_options_container:CampOptionsContainer
@export var records_options_container:CampOptionsContainer
@export var pretty_picture_texure_rect:TextureRect

@export var quest_button:CampOptionButton
@export var shop_button:CampOptionButton
@export var character_button:CampOptionButton
@export var explort_button:CampOptionButton
@export var records_button:CampOptionButton
@export var system_button:CampOptionButton

@export var sys_back_button:CampOptionButton
@export var sys_save_button:CampOptionButton
@export var sys_load_button:CampOptionButton
@export var sys_debug_button:CampOptionButton
@export var sys_quit_button:CampOptionButton

@export var rec_back_button:CampOptionButton
@export var rec_cards_button:CampOptionButton
@export var rec_pages_button:CampOptionButton
@export var rec_actors_button:CampOptionButton

@export var character_menu:CharacterMenuControl

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Instance = self
	if character_menu:
		character_menu.hide()
	character_button.button.pressed.connect(_on_prepare_button)
	quest_button.button.pressed.connect(_on_quest_button)
	shop_button.button.pressed.connect(_on_shop_button)
	explort_button.button.pressed.connect(_on_explore_button)
	records_button.button.pressed.connect(_sub_menu_open.bind("Records"))
	system_button.button.pressed.connect(_sub_menu_open.bind("System"))
	sys_back_button.button.pressed.connect(_sub_menu_open.bind("Main"))
	sys_save_button.button.pressed.connect(_on_save_button)
	sys_load_button.button.pressed.connect(_on_load_button)
	sys_debug_button.button.pressed.connect(_on_debug_button)
	sys_quit_button.button.pressed.connect(_on_quit)
	
	rec_back_button.button.pressed.connect(_sub_menu_open.bind("Main"))
	rec_cards_button.button.pressed.connect(_on_records)
	rec_pages_button.button.pressed.connect(_on_pages)
	rec_actors_button.button.pressed.connect(_on_actors)
	
	if StoryState.get_story_flag("CampShopDisabled"):
		shop_button.disabled = true
	if StoryState.get_story_flag("CampScribeDisabled"):
		system_button.disabled = true
	
	var location = StoryState.get_location()
	if location != "":
		var image_path = "res://Scenes/Menus/CampMenu/PrettyPictures/" + location.replace(' ', '') + ".png"
		var pretty_picture = SpriteCache.get_sprite(image_path)
		if pretty_picture:
			pretty_picture_texure_rect.texture = pretty_picture
			
	_sub_menu_open("Main")
	pass # Replace with function body.

func load_dialog(dialog_script:String):
	dialog_control.load_dialog_script(dialog_script)
	dialog_control.show()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _sub_menu_open(name:String):
	if name == "System":
		camp_options_container.hide()
		records_options_container.hide()
		system_options_container.show()
		system_options_container.resize_options = true
	elif name == "Records":
		camp_options_container.hide()
		system_options_container.hide()
		records_options_container.show()
		records_options_container.resize_options = true
	else:
		camp_options_container.show()
		system_options_container.hide()
		records_options_container.hide()

func _on_shop_button():
	MainRootNode.Instance.open_shop_menu()

func _on_quest_button():
	StoryState.load_next_story_scene()
	#MainRootNode.Instance.start_combat("res://Scenes/Maps/StoryMaps/2_Cross_Road/crossroad_dialog_map.tscn")
	#MainRootNode.Instance.load_dialog_scene("res://Scenes/Maps/StoryMaps/2_Cross_Road/crossroad_dialog_script.json")
	pass

func _on_explore_button():
	MainRootNode.Instance.open_map_selection_menu()

func _on_prepare_button():
	if character_menu and CharacterMenuControl.Instance != null:
		character_menu.show_menu()
	else:
		MainRootNode.Instance.open_character_sheet()
	#character_menu.show_menu()

func _on_records():
	var new_cards:TutorialCardsController = load("res://Scenes/TutorialCards/tutorial_cards.tscn").instantiate()
	self.add_child(new_cards)

func _on_pages():
	var new_cards = load("res://Scenes/Menus/PageLibraryMenu/page_library_menu.tscn").instantiate()
	self.add_child(new_cards)

func _on_actors():
	var new_cards = load("res://Scenes/Menus/ActorsLibrary/actors_library.tscn").instantiate()
	self.add_child(new_cards)
	

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
	Instance = null
	MainRootNode.Instance.go_to_main_menu()
