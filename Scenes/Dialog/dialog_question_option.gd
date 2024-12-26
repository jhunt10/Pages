class_name DialogQuestionOption
extends Control

@export var option_icon_texture_empty:Texture2D
@export var option_icon_texture_filled:Texture2D
@export var option_icon:TextureRect
@export var option_label:Label
@export var button:Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not MainRootNode.is_mobile:
		button.mouse_entered.connect(_mouse_enter)
		button.mouse_exited.connect(_mouse_exit)
		
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_option_text(text):
	option_label.text = text
	option_icon.texture = option_icon_texture_empty

func set_selected(val):
	if val:
		option_icon.texture = option_icon_texture_filled
	else:
		option_icon.texture = option_icon_texture_empty
	if  button.mouse_entered.is_connected(_mouse_enter):
		button.mouse_entered.disconnect(_mouse_enter)
	if  button.mouse_exited.is_connected(_mouse_exit):
		button.mouse_exited.disconnect(_mouse_exit)

func _mouse_enter():
	option_icon.texture = option_icon_texture_filled
func _mouse_exit():
	option_icon.texture = option_icon_texture_empty
