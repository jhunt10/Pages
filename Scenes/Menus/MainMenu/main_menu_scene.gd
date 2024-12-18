class_name MainMenuSceneControl
extends VBoxContainer
var root_node:MainRootNode = MainRootNode.Instance
@onready var main_container = $VBoxContainer
@onready var tutorial_button:TextureButton = $VBoxContainer/TutorialContainer/TutorialButton
@onready var start_button:TextureButton = $VBoxContainer/StartContainer/StartButton
@onready var load_button:TextureButton = $VBoxContainer/LoadContainer/LoadButton
@onready var more_button:TextureButton = $VBoxContainer/MoreContainer/MoreButton

@onready var more_container = $VBoxContainer2
@onready var back_button:TextureButton = $VBoxContainer2/BackContainer/BackButton
@onready var page_button:TextureButton = $VBoxContainer2/PagesContainer/PagesButton
@onready var effects_button:TextureButton = $VBoxContainer2/EffectsContainer/EffectsButton
@onready var dev_tools_button:TextureButton = $VBoxContainer2/DevToolsContainer/DevToolsButton

func _ready() -> void:
	#self.size = get_viewport_rect().size
	start_button.pressed.connect(start_combat)
	load_button.pressed.connect(_open_load_menu)
	page_button.pressed.connect(_open_page_edit)
	effects_button.pressed.connect(_open_effect_edit)
	tutorial_button.pressed.connect(_open_tutorial)
	dev_tools_button.pressed.connect(_dev_tools)
	more_button.pressed.connect(show_sub_menu.bind("More"))
	back_button.pressed.connect(show_sub_menu.bind("Main"))
	show_sub_menu("Main")

func show_sub_menu(name):
	if name == "More":
		more_container.show()
		main_container.hide()
	else:
		main_container.show()
		more_container.hide()
	pass

func start_combat():
	root_node.start_game()

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
