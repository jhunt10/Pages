class_name ItemDetailsCard
extends Control

signal exit_button_pressed
signal hide_done

@export var speed:float
@export var offset_control:Control
@export var icon:TextureRect
@export var title_lable:FitScaleLabel
@export var description_box:RichTextLabel
@export var exit_button:Button
#@export var equip_button:Button
#@export var button_label:Label

@export var weapon_details:WeaponDetailsControl
@export var armor_details:ArmorDetailsControl
@export var action_details:ActionDetailsControl
@export var page_que_details:PageQueDetailsControl
@export var default_details:DefaultItemDetailsControl
@export var tag_label:Label


@export var equip_button_background:NinePatchRect
@export var equip_button:Button
@export var equip_label:FitScaleLabel

enum AnimationStates {In, Showing, Out, Hidden}
var animation_state:AnimationStates
var item_id:String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	exit_button.pressed.connect(_on_exit_button)
	#equip_button.pressed.connect(equip_button_pressed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if animation_state == AnimationStates.Showing or animation_state == AnimationStates.Hidden:
		return
	
	var target = null
	if animation_state == AnimationStates.In:
		target = offset_control.position.move_toward(Vector2.ZERO, delta * speed)
	elif animation_state == AnimationStates.Out:
		target = offset_control.position.move_toward(Vector2(0, self.size.y), delta * speed)
	if offset_control.position.distance_to(target) < 1:
		if animation_state == AnimationStates.Out:
			animation_state = AnimationStates.Hidden
			self.hide()
			print("Done Showing")
			hide_done.emit()
		else:
			animation_state == AnimationStates.Showing
	else:
		offset_control.position = target

func _on_exit_button():
	exit_button_pressed.emit()
	start_hide()
	

func start_show():
	self.show()
	offset_control.position.y = self.size.y
	animation_state = AnimationStates.In

func start_hide():
	if animation_state == AnimationStates.Out or animation_state == AnimationStates.Hidden:
		return
	offset_control.position.y = 0
	animation_state = AnimationStates.Out

func set_item(actor:BaseActor, item:BaseItem):
	item_id = item.Id
	icon.texture = item.get_small_icon()
	title_lable.text = item.details.display_name
	description_box.text = item.details.description
	var tag_string = ''
	for tag in item.get_item_tags():
		tag_string += ", " + tag
	#var tag_label_text = ("[%s]: %s" % [item.ItemKey, tag_string.trim_prefix(", ")])
	tag_label.text = tag_string.trim_prefix(", ")
	default_details.hide()
	weapon_details.hide()
	armor_details.hide()
	action_details.hide()
	page_que_details.hide()
	if item is BaseWeaponEquipment:
		var weapon = (item as BaseWeaponEquipment)
		weapon_details.set_weapon(actor, weapon)
		weapon_details.show()
	elif item is BaseArmorEquipment:
		var armor = (item as BaseArmorEquipment)
		armor_details.set_armor(actor, armor)
		armor_details.show()
	elif item is BasePageItem:
		var page = (item as BasePageItem)
		if page.get_action_key():
			action_details.set_action(actor, page)
			action_details.show()
		else:
			default_details.set_item(item)
			default_details.show()
	elif item is BaseQueEquipment:
		page_que_details.set_item(actor, item)
		page_que_details.show()
	else:
		default_details.set_item(item)
		default_details.show()
		#if equipment.get_equipt_to_actor_id():
			#button_label.text = "Remove"
		#else:
			#button_label.text = "Equipt"
	self.start_show()

func equip_button_pressed():
	if weapon_details.visible:
		weapon_details.on_eqiup_button_pressed()
	elif armor_details.visible:
		armor_details.on_eqiup_button_pressed()
	elif action_details.visible:
		action_details.on_eqiup_button_pressed()
	elif default_details.visible:
		default_details.on_eqiup_button_pressed()
