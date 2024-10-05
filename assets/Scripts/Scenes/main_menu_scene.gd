class_name MainMenuSceneControl
extends VBoxContainer

@onready var root_node:MainRootNode = $".."
@onready var start_button:TextureButton = $StartContainer/StartButton
@onready var page_button:TextureButton = $PagesContainer/PagesButton
@onready var character_button:TextureButton = $CharacterContainer/CharacterButton

func _ready() -> void:
	#self.size = get_viewport_rect().size
	start_button.pressed.connect(start_combat)
	character_button.pressed.connect(_open_character_edit)
	page_button.pressed.connect(_open_page_edit)

func start_combat():
	root_node.start_combat()

func _open_character_edit():
	root_node.open_character_sheet()

func _open_page_edit():
	root_node.open_page_editor()
