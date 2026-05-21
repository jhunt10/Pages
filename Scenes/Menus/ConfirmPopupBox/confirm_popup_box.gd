class_name ConfirmPopupBox
extends Control

@export var title_label:Label
@export var info_button:TextureButton
@export var close_button:TextureButton
@export var rich_text_label:RichTextLabel
@export var cancel_button:Button
@export var ok_button:Button

var on_confirm_func:Callable
var on_cancel_func:Callable

func set_confirm_data(title:String, message:String, on_confirm:Callable, on_cancel:Callable):
	title_label.text = title
	rich_text_label.text = message
	on_confirm_func = on_confirm
	on_cancel_func = on_cancel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close_button.pressed.connect(_on_cancel_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)
	ok_button.pressed.connect(_on_confirm_pressed)

func _on_confirm_pressed():
	if on_confirm_func:
		on_confirm_func.call()
	self.queue_free()

func _on_cancel_pressed():
	if on_confirm_func:
		on_cancel_func.call()
	self.queue_free()
