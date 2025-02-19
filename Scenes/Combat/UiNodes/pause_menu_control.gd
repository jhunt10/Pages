class_name PauseMenuControl
extends Control

@onready var main_menu_button:TextureButton = $HBoxContainer/VBoxContainer/ButtonContainer/MainMenuButton
@onready var to_camp_button:TextureButton = $HBoxContainer/VBoxContainer/ButtonContainer2/ToCampButton
@onready var close_button:TextureButton = $HBoxContainer/VBoxContainer/ButtonContainer3/ReturnButton
@onready var character_button:TextureButton = $HBoxContainer/VBoxContainer/ButtonContainer4/CharacterButton

func _ready() -> void:
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	to_camp_button.pressed.connect(_on_to_camp)
	close_button.pressed.connect(_on_close_menu)
	#character_button.visible = false
	character_button.pressed.connect(_on_character)
	if CombatRootControl.Instance.is_story_map:
		to_camp_button.hide()

func _on_main_menu_pressed():
	MainRootNode.Instance.go_to_main_menu()

func _on_to_camp():
	MainRootNode.Instance.open_camp_menu()

func _on_close_menu():
	CombatUiControl.ui_state_controller.back_to_last_state()

func _on_character():
			CombatUiControl.ui_state_controller.set_ui_state(
				UiStateController.UiStates.CharacterSheet, 
				{"ActorId":CombatUiControl.Instance.stat_panel_control.actor.Id},
				false)
	
