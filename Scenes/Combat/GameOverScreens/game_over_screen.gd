class_name GameOverScreen
extends Control

@export var to_camp_button:Button
@export var main_menu_button:Button

func _ready() -> void:
	main_menu_button.pressed.connect(on_main_menu)
	to_camp_button.pressed.connect(on_camp_button)

func on_main_menu():
	CombatRootControl.Instance.cleanup_combat()
	MainRootNode.Instance.go_to_main_menu()

func on_camp_button():
	CombatRootControl.Instance.cleanup_combat()
	MainRootNode.Instance.open_camp_menu()
	
