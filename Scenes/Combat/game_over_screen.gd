class_name GameOverScreen
extends Control

@export var main_menu_button:Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_menu_button.pressed.connect(on_main_menu)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_main_menu():
	MainRootNode.Instance.go_to_main_menu()
