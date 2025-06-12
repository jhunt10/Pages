class_name MainMenuSceneControl
extends VBoxContainer
var root_node:MainRootNode = MainRootNode.Instance
@onready var main_container = $VBoxContainer
@onready var tutorial_button:TextureButton = $VBoxContainer/TutorialContainer/TutorialButton
@onready var pages_button:TextureButton = $VBoxContainer/PagesContainer/PagesButton
@onready var start_button:TextureButton = $VBoxContainer/StartContainer/StartButton
@onready var load_button:TextureButton = $VBoxContainer/LoadContainer/LoadButton
@onready var more_button:TextureButton = $VBoxContainer/MoreContainer/MoreButton
@onready var quit_button:TextureButton = $VBoxContainer/QuitContainer/QuitButton

@onready var more_container = $VBoxContainer2
@onready var back_button:TextureButton = $VBoxContainer2/BackContainer/BackButton
@onready var page_button:TextureButton = $VBoxContainer2/PagesContainer/PagesButton
@onready var effects_button:TextureButton = $VBoxContainer2/EffectsContainer/EffectsButton
@onready var dev_tools_button:TextureButton = $VBoxContainer2/DevToolsContainer/DevToolsButton
@onready var animation_button:TextureButton = $VBoxContainer2/AnimationTesterContainer/AnimationsButton

func _ready() -> void:
	#self.size = get_viewport_rect().size
	start_button.pressed.connect(start_combat)
	load_button.pressed.connect(_open_load_menu)
	page_button.pressed.connect(_open_page_edit)
	effects_button.pressed.connect(_open_effect_edit)
	tutorial_button.pressed.connect(_open_tutorial)
	dev_tools_button.pressed.connect(_dev_tools)
	animation_button.pressed.connect(_open_animation_tester)
	pages_button.pressed.connect(_open_pages_menu)
	more_button.pressed.connect(show_sub_menu.bind("More"))
	back_button.pressed.connect(show_sub_menu.bind("Main"))
	quit_button.pressed.connect(quit_game)
	show_sub_menu("Main")

func quit_game():
	get_tree().quit()

func show_sub_menu(menu_name):
	if menu_name == "More":
		more_container.show()
		main_container.hide()
	else:
		main_container.show()
		more_container.hide()
	pass

func start_combat():
	StoryState.start_new_story()

func _open_pages_menu():
	var new_cards = load("res://Scenes/Menus/PageLibraryMenu/page_library_menu.tscn").instantiate()
	root_node.add_child(new_cards)
	

func _open_load_menu():
	root_node.open_load_menu()

func _open_page_edit():
	root_node.open_page_editor()
func _open_effect_edit():
	root_node.open_effect_editor()

func _open_tutorial():
	root_node.open_tutorial()

func _dev_tools():
	root_node.open_dev_tools()

func _open_animation_tester():
	root_node.open_animation_tester()
