class_name PauseMenuControl
extends Control

@export var main_container:Container

@export var main_menu_button:Button 
@export var to_camp_button:Button
@export var cancel_button:Button
@export var close_button:TextureButton

func _ready() -> void:
	main_menu_button.pressed.connect(_on_main_menu)
	to_camp_button.pressed.connect(_on_to_camp)
	cancel_button.pressed.connect(_on_close_menu)
	close_button.pressed.connect(_on_close_menu)

func _on_main_menu():
	# TODO: Translation
	MainRootNode.Instance.create_confirm_popup(
		"Confirm Quit",
		"Exit to Main Menu?
[b][color=#770000]Unsaved data will be lost.[b]",
		_on_main_menu_confirm,
		_on_confirm_canceled,
		self
		)
	main_container.hide()

func _on_main_menu_confirm():
	CombatRootControl.Instance.cleanup_combat()
	MainRootNode.Instance.go_to_main_menu()

func _on_to_camp():
	# TODO: Translation
	MainRootNode.Instance.create_confirm_popup(
		"Confirm Retreat",
		"Return to Camp?",
		_on_to_camp_confirmed,
		_on_confirm_canceled,
		self
		)
	main_container.hide()

func _on_confirm_canceled():
	main_container.show()
	pass

func _on_to_camp_confirmed():
	CombatRootControl.Instance.cleanup_combat()
	MainRootNode.Instance.open_camp_menu()

func _on_close_menu():
	if CombatUiControl.ui_state_controller.current_ui_state is UiState_PauseMenu:
		CombatUiControl.ui_state_controller.back_to_last_state()
	else:
		self.hide()

func _on_character():
			CombatUiControl.ui_state_controller.set_ui_state(
				UiStateController.UiStates.CharacterSheet, 
				{"ActorId":CombatUiControl.Instance.stat_panel_control.actor.Id},
				false)
