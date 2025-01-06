class_name DialogTextInput
extends Control

signal input_confirmed(val:String)

@export var card_patch:NinePatchRect
@export var box_container:BoxContainer
@export var title_label:Label
@export var line_edit:LineEdit
@export var confirm_button:Button

func set_texts(title_text:String, place_holder:String):
	title_label.text = title_text
	line_edit.text = ''
	line_edit.placeholder_text = place_holder
	var min_size = title_label.get_minimum_size()
	if card_patch.size.x < min_size.x + box_container.offset_left - box_container.offset_right:
		card_patch.size.x = min_size.x + box_container.offset_left - box_container.offset_right

func _ready() -> void:
	confirm_button.pressed.connect(_on_button_pressed)
	var min_size = title_label.get_minimum_size()
	if card_patch.size.x < min_size.x + box_container.offset_left - box_container.offset_right:
		card_patch.size.x = min_size.x + box_container.offset_left - box_container.offset_right

func _on_button_pressed():
	var text = line_edit.text
	if not text or text == '':
		text = line_edit.placeholder_text
	input_confirmed.emit(text)
	self.queue_free()
