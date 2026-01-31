class_name PauseMenuControl
extends Control

@onready var main_container:Container = $HBoxContainer/MainContainer
@onready var main_menu_button:TextureButton = $HBoxContainer/MainContainer/ButtonContainer/MainMenuButton
@onready var to_camp_button:TextureButton = $HBoxContainer/MainContainer/ButtonContainer2/ToCampButton
@onready var close_button:TextureButton = $HBoxContainer/MainContainer/ButtonContainer3/ReturnButton
@onready var character_button:TextureButton = $HBoxContainer/MainContainer/ButtonContainer4/CharacterButton

@onready var exit_container:Container = $HBoxContainer/ConfirmExitContainer
@onready var exit_back_button:TextureButton = $HBoxContainer/ConfirmExitContainer/BackButtonContainer/BackButton
@onready var exit_confirm_button:TextureButton = $HBoxContainer/ConfirmExitContainer/ContinueContainer/MainMenuButton

func _ready() -> void:
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	to_camp_button.pressed.connect(_on_to_camp)
	close_button.pressed.connect(_on_close_menu)
	#character_button.visible = false
	character_button.pressed.connect(_on_character)
	
	exit_back_button.pressed.connect(_on_main_menu_back)
	exit_confirm_button.pressed.connect(_on_main_menu_confirm)
	
	main_container.show()
	exit_container.hide()
	
	#if CombatRootControl.Instance.is_story_map:
		#to_camp_button.hide()

func _on_main_menu_pressed():
	main_container.hide()
	exit_container.show()

func _on_main_menu_back():
	main_container.show()
	exit_container.hide()

func _on_main_menu_confirm():
	CombatRootControl.Instance.cleanup_combat()
	MainRootNode.Instance.go_to_main_menu()

func _on_to_camp():
	CombatRootControl.Instance.cleanup_combat()
	MainRootNode.Instance.open_camp_menu()

func _on_close_menu():
	CombatUiControl.ui_state_controller.back_to_last_state()

func _on_character():
			CombatUiControl.ui_state_controller.set_ui_state(
				UiStateController.UiStates.CharacterSheet, 
				{"ActorId":CombatUiControl.Instance.stat_panel_control.actor.Id},
				false)
	
