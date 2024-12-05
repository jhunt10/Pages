class_name ItemDetailsCard
extends Control

signal action_button_pressed
signal hide_done

@export var speed:float
@export var offset_control:Control
@export var icon:TextureRect
@export var title_lable:Label
@export var description_box:RichTextLabel
@export var exit_button:Button
@export var equip_button:Button
@export var button_label:Label

enum AnimationStates {In, Showing, Out, Hidden}
var animation_state:AnimationStates
var item_id:String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	exit_button.pressed.connect(self.start_hide)
	equip_button.pressed.connect(equip_button_pressed)
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

func start_show():
	self.show()
	offset_control.position.y = self.size.y
	animation_state = AnimationStates.In

func start_hide():
	if animation_state == AnimationStates.Out or animation_state == AnimationStates.Hidden:
		return
	offset_control.position.y = 0
	animation_state = AnimationStates.Out

func set_item(item:BaseItem):
	item_id = item.Id
	icon.texture = item.get_small_icon()
	title_lable.text = item.details.display_name
	description_box.text = item.details.description
	if item is BaseEquipmentItem:
		var equipment = (item as BaseEquipmentItem)
		if equipment.get_equipt_to_actor_id():
			button_label.text = "Remove"
		else:
			button_label.text = "Equipt"
	self.start_show()

func equip_button_pressed():
	action_button_pressed.emit()
