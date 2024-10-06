class_name PopUpWarningControl
extends Control

@onready var text_box:Label = $MessageBoxContainer/VBoxContainer/VBoxContainer/Label
@onready var confirm_button:TextureButton = $MessageBoxContainer/VBoxContainer/HBoxContainer/ConfirmButton
@onready var confirm_button_label:Label = $MessageBoxContainer/VBoxContainer/HBoxContainer/ConfirmButton/Label
@onready var cancel_button:TextureButton = $MessageBoxContainer/VBoxContainer/HBoxContainer/CancelButton
@onready var cancel_button_label:Label = $MessageBoxContainer/VBoxContainer/HBoxContainer/CancelButton/Label

var on_confirm:Callable 
var on_cancel:Callable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false
	confirm_button.pressed.connect(_on_confirm_button_pressed)
	cancel_button.pressed.connect(_on_cancel_button_pressed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func show_pop_up(message:String, on_confirm_func:Callable, comfirm_button_text:String='Confirm'):
	text_box.text = message
	on_confirm = on_confirm_func
	confirm_button_label.text = comfirm_button_text
	self.visible = true

func _on_confirm_button_pressed():
	if on_confirm:
		on_confirm.call()
	self.visible = false
	
func _on_cancel_button_pressed():
	if on_cancel:
		on_cancel.call()
	self.visible = false
