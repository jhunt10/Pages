@tool
class_name ItemDetailsCard
extends Control

signal exit_button_pressed
signal hide_done
signal item_confirmed(item:BaseItem)


enum States {Hidden, Growing, Showing, Shrinking}

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
@export var icon:TextureRect
@export var icon_background:TextureRect
@export var title_lable:FitScaleLabel
@export var rarity_lable:Label
@export var description_box:RichTextLabel
@export var exit_button:Button
#@export var equip_button:Button
#@export var button_label:Label

@export var weapon_details:WeaponDetailsControl
@export var armor_details:ArmorDetailsControl
@export var action_details:ActionDetailsControl
@export var effect_page_details:EffectPageDetailsControl
@export var page_que_details:PageQueDetailsControl
@export var default_details:DefaultItemDetailsControl
@export var tag_label:Label
@export var tag_box:TagBox


@export var confirm_button_background:NinePatchRect
@export var confirm_button:Button
@export var confirm_label:FitScaleLabel
@export var confirm_button_texture:Texture2D
@export var confirm_button_pressed_texture:Texture2D

@export var buy_controller:BuyController
#enum AnimationStates {In, Showing, Out, Hidden}
#var animation_state:AnimationStates
var item_id:String
var actor_has_item:bool = false
var _current_card
var _actor:BaseActor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	exit_button.pressed.connect(_on_exit_button)
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
	if state == States.Hidden or state == States.Showing:
		return
	if state == States.Growing:
		grow_timer = min(time_to_show, grow_timer + delta)
		var distance = offset_point.position
		offset_control.position = distance * (1 - (grow_timer / time_to_show))
		if time_to_show == grow_timer:
			state = States.Showing
	if state == States.Shrinking:
		grow_timer = max(0, grow_timer - delta)
		var distance = offset_point.position
		offset_control.position = distance * (1-(grow_timer / time_to_show))
		if grow_timer == 0:
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
	icon_background.texture = item.get_rarity_background()
	icon.texture = item.get_small_icon()
	title_lable.text = item.get_display_name()
	rarity_lable.text = item.get_rarity_string() + " " + item.get_taxonomy_leaf()
	#description_box.text = item.get_description()
	#var tag_string = ''
	#for tag in item.get_tags():
		#tag_string += ", " + tag
	##var tag_label_text = ("[%s]: %s" % [item.ItemKey, tag_string.trim_prefix(", ")])
	#tag_label.text = tag_string.trim_prefix(", ")
	tag_box.set_tags(item.get_tags())
	default_details.hide()
	weapon_details.hide()
	armor_details.hide()
	action_details.hide()
	effect_page_details.hide()
	page_que_details.hide()
	
	actor_has_item = false
	if item is BaseWeaponEquipment:
		var weapon = (item as BaseWeaponEquipment)
		weapon_details.set_weapon(actor, weapon)
		if actor:
			actor_has_item = actor.equipment.has_item(item_id)
		_current_card = weapon_details
		weapon_details.show()
	elif item is BaseApparelEquipment:
		var armor = (item as BaseApparelEquipment)
		armor_details.set_armor(actor, armor)
		if actor:
			actor_has_item = actor.equipment.has_item(item_id)
		_current_card = armor_details
		armor_details.show()
	elif item is BasePageItem:
		var page = (item as BasePageItem)
		if item is PageItemAction:
			action_details.set_action(actor, page)
			if actor:
				actor_has_item = actor.pages.has_item(item_id)
			_current_card = action_details
			action_details.show()
		else:
			effect_page_details.set_action(actor, page)
			if actor:
				actor_has_item = actor.pages.has_item(item_id)
			_current_card = effect_page_details
			effect_page_details.show()
			#default_details.set_item(item)
			#default_details.show()
	elif item is BaseQueEquipment:
		page_que_details.set_item(actor, item)
		if actor:
			actor_has_item = actor.equipment.has_item(item_id)
		_current_card = page_que_details
		page_que_details.show()
	else:
		default_details.set_item(item)
		if actor:
			actor_has_item = actor.equipment.has_item(item_id)
		_current_card = default_details
		default_details.show()
	
	# Shop controls
	if MainRootNode.Instance.current_scene is ShopMenuController:
		buy_controller.set_item(item, is_selling)
		buy_controller.show()
		confirm_button_background.hide()
	# Hide Confirm Button in combat
	elif MainRootNode.Instance.current_scene is CombatRootControl:
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
