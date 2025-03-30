class_name EffectIconControl
extends Control

signal icon_hovered(effect_id)

@export var background:TextureRect
@export var effect_icon:TextureRect
@export var count_label:Label

@export var description_box:Container

@export var buff_background_texture:Texture2D
@export var bane_background_texture:Texture2D

var effect_id:String
var hover_timer:float

func _ready() -> void:
	self.mouse_entered.connect(_on_mouse_entered)
	self.mouse_exited.connect(_on_mouse_exited)
	description_box.hide()

func _process(delta: float) -> void:
	if hover_timer > 0:
		hover_timer -= delta
		if hover_timer <= 0:
			description_box.show()
			icon_hovered.emit(effect_id)
	

func set_effect(effect:BaseEffect):
	effect_id = effect.Id
	effect_icon.texture = effect.get_small_icon()
	
	if effect.show_counter():
		count_label.show()
		count_label.text = str(effect.RemainingDuration)
	else:
		count_label.hide()
		
	if effect.is_good():
		background.texture = buff_background_texture
	if effect.is_bad():
		background.texture = bane_background_texture
	if description_box:
		description_box.set_effect(effect)

func _on_mouse_entered():
	hover_timer = 0.5

func _on_mouse_exited():
	hover_timer = -1
	description_box.hide()
