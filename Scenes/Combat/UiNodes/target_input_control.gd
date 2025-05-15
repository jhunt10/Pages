class_name TargetInputControl
extends Control


@export var button:Button
@export var title_label:Label
@export var button_label:Label

# Not using signals because UI_States pop in and out. Binding might get messy
var on_pressed_func

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.pressed.connect(_on_button_pressed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func set_title_text(text):
	title_label.text = text

func set_button_text(text):
	button_label.text = text

func _on_button_pressed():
	if on_pressed_func:
		on_pressed_func.call()
