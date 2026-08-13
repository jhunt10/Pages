class_name ActorDeploymentControl
extends Control
signal cancled

@export var close_button:TextureButton
@export var cancel_button:Button

@export var sub_actors_container:BoxContainer
@export var sub_actors_options_container:BoxContainer
@export var premade_sub_actor_option:BoxContainer
var sub_actor_check_boxes:Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close_button.pressed.connect(on_canceled_button)
	cancel_button.pressed.connect(on_canceled_button)
	for child in sub_actors_options_container.get_children():
		if not child == premade_sub_actor_option:
			child.queue_free()
	premade_sub_actor_option.hide()
		
	pass # Replace with function body.

func on_canceled_button():
	cancled.emit()

func set_deploying_actor(carrier:CarrierActor, actor:BaseActor):
	sub_actor_check_boxes.clear()
	for child in sub_actors_options_container.get_children():
		if not child == premade_sub_actor_option:
			child.queue_free()
	
	if actor is CarrierActor:
		sub_actors_container.show()
		for child:BaseActor in carrier.list_carried_actors():
			if child == actor:
				continue
			var option = premade_sub_actor_option.duplicate()
			var portarit :TextureRect= option.get_node("PortraitBackground/PortraitTextureRect")
			portarit.texture = child.get_small_icon()
			var check_box = option.get_node("CheckBox")
			sub_actor_check_boxes[child.Id] = check_box
			sub_actors_options_container.add_child(option)
			option.show()
	else:
		sub_actors_container.hide()

func list_selected_sub_actor_ids()->Array:
	var out_list = []
	for actor_id in sub_actor_check_boxes.keys():
		var check_box:CheckBox = sub_actor_check_boxes[actor_id]
		if check_box.button_pressed:
			out_list.append(actor_id)
	return out_list
