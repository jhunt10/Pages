class_name TargetInputControl
extends Control

signal confirmed
signal canceled

@export var close_button:TextureButton
@export var comfirm_button:Button
@export var cancel_button:Button
@export var title_label:Label
@export var target_type_label:Label
@export var unknown_icon_texture:Texture2D

@export var actor_portrait:TextureRect
@export var page_icon:TextureRect
@export var page_details:QuePageHoverBox
@export var lock_on_container:Container
@export var lock_on_box:CheckBox

@export var target_icon:TextureRect
@export var target_icon_container:TextureRect
@export var target_npc_index_label:Label

@export var spot_container:Container
@export var x_label:Label
@export var y_label:Label

var target_type:TargetParameters.TargetTypes

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	page_details.hide()
	close_button.pressed.connect(_on_cancel_or_close_buttons)
	cancel_button.pressed.connect(_on_cancel_or_close_buttons)
	comfirm_button.pressed.connect(_on_confirm_button)
	page_icon.mouse_entered.connect(show_hover_box)
	page_icon.mouse_exited.connect(hide_hover_box)

func _on_cancel_or_close_buttons():
	canceled.emit()

func _on_confirm_button():
	confirmed.emit()

func set_confirm_enabled(val:bool):
	comfirm_button.disabled = !val

func set_title_text(text):
	title_label.text = text
	
func set_target_type(type:TargetParameters.TargetTypes, allow_lockon:bool=true):
	target_type_label.text = TargetParameters.TargetTypes.keys()[type]
	target_type = type
	if TargetParameters.ActorTargetTypes.has(target_type):
		spot_container.hide()
		if allow_lockon:
			lock_on_container.show()
		else:
			lock_on_container.hide()
			lock_on_box.button_pressed = false
		target_icon_container.show()
		match target_type:
			TargetParameters.TargetTypes.Actor:
				target_type_label.add_theme_color_override("font_color", Color.BLUE)
			TargetParameters.TargetTypes.Enemy:
				target_type_label.add_theme_color_override("font_color", Color.FIREBRICK)
			TargetParameters.TargetTypes.Ally:
				target_type_label.add_theme_color_override("font_color", Color.WEB_GREEN)
				
	else:
		target_icon_container.hide()
		lock_on_container.hide()
		spot_container.show()

func set_actor(actor:BaseActor):
	var turn = CombatRootControl.Instance.GameState.current_turn_index
	var page = actor.Que.get_action_for_turn(turn)
	
	actor_portrait.texture = actor.sprite.get_portrait_sprite()
	page_icon.texture = page.get_large_page_icon(actor)
	page_details.set_action(actor, page)
	# Clear target portrait
	target_icon.texture = unknown_icon_texture
	target_npc_index_label.text = ''
	x_label.text = ""
	y_label.text = ""
	x_label.add_theme_color_override("font_color", Color.BLACK)
	y_label.add_theme_color_override("font_color", Color.BLACK)

func set_target_coord(coord:Vector2i):
	if TargetParameters.ActorTargetTypes.has(target_type):
		var targets = CombatRootControl.Instance.GameState.get_actors_at_pos(coord)
		var target = targets[0]
		target_icon.texture = target.sprite.get_portrait_sprite()
		target_npc_index_label.text = target.get_npc_index_str()
	else:
		target_icon_container.hide()
		x_label.text = str(coord.x)
		x_label.add_theme_color_override("font_color", Color.BLACK)
		y_label.text = str(coord.y)
		y_label.add_theme_color_override("font_color", Color.BLACK)
		spot_container.show()

func set_invalid_target_coord(coord:Vector2i):
	target_icon.texture = unknown_icon_texture
	target_npc_index_label.text = ''
	x_label.text = str(coord.x)
	x_label.add_theme_color_override("font_color", Color("#780000", 1.0))
	y_label.text = str(coord.y)
	y_label.add_theme_color_override("font_color", Color("#780000", 1.0))
	if TargetParameters.ActorTargetTypes.has(target_type):
		spot_container.hide()
		target_icon_container.show()
	else:
		target_icon_container.hide()
		spot_container.show()

func show_hover_box():
	page_details.show_self()

func hide_hover_box():
	page_details.hide()
