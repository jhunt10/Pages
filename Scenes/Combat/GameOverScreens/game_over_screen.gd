class_name GameOverScreen
extends Control

@export var main_menu_button:Button

func _ready() -> void:
	main_menu_button.pressed.connect(on_main_menu)

func on_main_menu():
	CombatRootControl.Instance.cleanup_combat()
	MainRootNode.Instance.go_to_main_menu()
