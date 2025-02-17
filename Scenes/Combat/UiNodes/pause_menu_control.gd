class_name PauseMenuControl
extends Control

@onready var main_menu_button:TextureButton = $HBoxContainer/VBoxContainer/ButtonContainer/MainMenuButton
@onready var quit_button:TextureButton = $HBoxContainer/VBoxContainer/ButtonContainer2/QuitButton
@onready var close_button:TextureButton = $HBoxContainer/VBoxContainer/ButtonContainer3/ReturnButton
@onready var character_button:TextureButton = $HBoxContainer/VBoxContainer/ButtonContainer4/CharacterButton

func _ready() -> void:
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	close_button.pressed.connect(_on_close_menu)
	#character_button.visible = false
	character_button.pressed.connect(_on_character)

func _on_main_menu_pressed():
	MainRootNode.Instance.go_to_main_menu()

func _on_quit_pressed():
	get_tree().quit()

func _on_close_menu():
	CombatUiControl.ui_state_controller.back_to_last_state()

func _on_character():
			CombatUiControl.ui_state_controller.set_ui_state(
				UiStateController.UiStates.CharacterSheet, 
				{"ActorId":CombatUiControl.Instance.stat_panel_control.actor.Id},
				false)
	
