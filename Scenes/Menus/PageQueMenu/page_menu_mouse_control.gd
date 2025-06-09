class_name PageMenuMouseControl
extends Control

@export var mouse_over_message_container:BackPatchContainer
@export var mouse_over_label:Label
@export var drag_page_control:Control
@export var drag_icon_texture_rect:TextureRect

func _ready() -> void:
	mouse_over_message_container.visible = false
	drag_page_control.visible = false

func set_dragging_page(page:BaseAction):
	if !page:
		drag_page_control.visible = false
		drag_icon_texture_rect.texture = null
		return
		
	drag_page_control.visible = true
	drag_icon_texture_rect.texture = page.get_large_page_icon()
	if mouse_over_message_container.visible:
		clear_message()
	
func set_hover_page(page:BaseAction):
	if drag_page_control.visible:
		return
	mouse_over_message_container.visible = true
	mouse_over_label.text = page.details.display_name + "\n" + page.get_snippet()

func clear_message():
	mouse_over_message_container.visible = false
	mouse_over_label.text = ''
