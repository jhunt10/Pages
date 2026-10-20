@tool
class_name ItemDetailsCard
extends Control

signal exit_button_pressed
signal hide_done
signal item_confirmed(item:BaseItem)


enum States {Hidden, Growing, Showing, Shrinking}

@export var exmple:String

@export var showing:bool:
	set(val):
		showing = val
		if showing and (state == States.Hidden or state == States.Shrinking):
			state = States.Growing
			grow_timer = 0
		if not showing and (state == States.Showing or state == States.Growing):
			state = States.Shrinking
			grow_timer = time_to_show

@export var state:States:
	set(val):
		state = val
		if offset_control and offset_point:
			if state == States.Hidden:
				grow_timer = 0
				offset_control.position = offset_point.position
			if state == States.Showing:
				grow_timer = time_to_show
				offset_control.position = Vector2.ZERO

var is_selling:bool = false
@export var shop_mode:bool:
	set(val):
		shop_mode = val
		#if buy_controller:
			#if shop_mode:
				#buy_controller.show()
				#equip_button_background.hide()
			#else:
				#buy_controller.hide()
				#equip_button_background.show()
			
@export var offset_control:Control
@export var offset_point:Node2D
@export var vertical:bool:
	set(val):
		vertical = val
		if offset_point:
			if vertical:
				offset_point.position = Vector2(self.size.x,0)
			else:
				offset_point.position = Vector2(0,self.size.y)

@export var time_to_show:float
@export var grow_timer:float

@export var speed:float

@export var item_details_container:ItemDetailsContainer


@export var confirm_button_background:NinePatchRect
@export var confirm_button:Button
@export var confirm_label:FitScaleLabel
@export var confirm_button_texture:Texture2D
@export var confirm_button_pressed_texture:Texture2D

#enum AnimationStates {In, Showing, Out, Hidden}
#var animation_state:AnimationStates
var item_id:String
var actor_has_item:bool = false
var _current_card
#var _actor:BaseActor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	item_details_container.exit_button.pressed.connect(_on_exit_button)
	offset_control.size = self.size
	if vertical:
		offset_point.position = Vector2(self.size.x,0)
	else:
		offset_point.position = Vector2(0,self.size.y)
	confirm_button.button_down.connect(equip_button_pressed)
	confirm_button.button_up.connect(equip_button_released)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if not self.visible:
		return
	if _qued_hide:
		if showing:
			start_hide()
	_qued_hide = false
	if state == States.Hidden or state == States.Showing:
		return
	
	if state == States.Growing:
		var lerp_wieght = self.global_position.distance_to(offset_point.global_position) * delta * (1.0/time_to_show)
		offset_control.global_position = offset_control.global_position.move_toward(self.global_position, lerp_wieght)
		var distance = offset_control.global_position.distance_to(self.global_position)
		if distance  <= 1:
			state = States.Showing
	if state == States.Shrinking:
		var lerp_wieght = self.global_position.distance_to(offset_point.global_position) * delta * (1.0/time_to_show)
		offset_control.global_position = offset_control.global_position.move_toward(offset_point.global_position, lerp_wieght)
		var distance = offset_control.global_position.distance_to(offset_point.global_position)
		if distance  <= 5:
			state = States.Hidden
			hide_done.emit()
			self.queue_free()
		#
	#var target = null
	#if animation_state == AnimationStates.In:
		#var self_hight = self.get_global_rect().size.y
		#target = offset_control.position.move_toward(Vector2(0, -self_hight), delta * speed)
	#elif animation_state == AnimationStates.Out:
		#target = offset_control.position.move_toward(Vector2.ZERO, delta * speed)
	#var offset_pos = offset_control.position
	#var dist_to_target = abs(offset_control.position.distance_to(target)) 
	#if dist_to_target < 1:
		#if animation_state == AnimationStates.Out:
			#animation_state = AnimationStates.Hidden
			#self.hide()
			#print("Done Showing")
			#hide_done.emit()
		#else:
			#animation_state = AnimationStates.Showing
	#else:
		#offset_control.position = target

func _on_exit_button():
	exit_button_pressed.emit()
	start_hide()

var _qued_hide = false
func que_hide():
	_qued_hide = true
	

func start_show():
	showing = true
	#confirm_button_background.texture = confirm_button_texture
	#self.show()
	#offset_control.position.y = self.size.y
	#animation_state = AnimationStates.In

func start_hide():
	showing = false
	#if animation_state == AnimationStates.Out or animation_state == AnimationStates.Hidden:
		#return
	##offset_control.position.y = 0
	#animation_state = AnimationStates.Out

func set_detail_card_item(actor:BaseActor, item:BaseItem, confirm_button_text:String, disable_confirm:bool=false):
	item_id = item.Id
	item_details_container.set_detail_container_item(actor, item)
	
	# Hide Confirm Button in combat
	if MainRootNode.Instance.current_scene is CombatRootControl:
		confirm_button_background.hide()
	else:
		# Hide Confirm Button for Titles
		if item.get_tags().has("Title"):
			confirm_button_background.hide()
		# Only show confirm if message provided
		elif confirm_button_text == "":
			confirm_button_background.hide()
		else:
			confirm_label.text = confirm_button_text
			confirm_label._size_dirty = true
			confirm_button_background.show()
			if disable_confirm:
				confirm_button_background.texture = confirm_button_pressed_texture
				confirm_button.disabled = true
			else:
				confirm_button_background.texture = confirm_button_texture
				confirm_button.disabled = false
	
	self.start_show()

func equip_button_pressed():
	confirm_button_background.texture = confirm_button_pressed_texture

func equip_button_released():
	confirm_button_background.texture = confirm_button_texture
	var item = ItemLibrary.get_item(item_id)
	if item:
		item_confirmed.emit(item)
