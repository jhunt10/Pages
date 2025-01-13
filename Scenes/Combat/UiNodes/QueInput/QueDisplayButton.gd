class_name QueDisplayButton
extends Control

@export var background:TextureRect
@export var page_icon:TextureRect
@export var button:Button

@export var empty_background_texture:Texture2D
@export var gap_background_texture:Texture2D
@export var filled_background_texture:Texture2D

var is_gap:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_is_gap(val:bool):
	is_gap = val
	background.texture = gap_background_texture
	if is_gap:
		page_icon.hide()
		button.hide()
		
func set_action(index:int, actor:BaseActor, action:BaseAction):
	if action and not is_gap:
		page_icon.visible = true
		background.texture = filled_background_texture
		page_icon.texture = action.get_qued_icon(index, actor)
	else:
		if is_gap:
			background.texture = gap_background_texture
		else:
			background.texture = empty_background_texture
		page_icon.visible = false
		page_icon.texture = null
