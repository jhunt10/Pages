class_name ActorDeploymentControl
extends Control

signal cancled
signal confirmed

@export var close_button:TextureButton
@export var cancel_button:Button
@export var confirm_button:Button

@export var actor_buttons_control:DeployActorButtons
var sub_actor_check_boxes:Dictionary = {}

var deployment_ui_state:UiState_DeploymentOnQue

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close_button.pressed.connect(on_canceled_button)
	cancel_button.pressed.connect(on_canceled_button)
	confirm_button.pressed.connect(on_confirm)
		
	pass # Replace with function body.

func on_canceled_button():
	cancled.emit()

func on_confirm():
	confirmed.emit()

func set_deploying_actor(carrier:CarrierActor, actor:BaseActor):
	#sub_actor_check_boxes.clear()
	#for child in sub_actors_options_container.get_children():
		#if not child == premade_sub_actor_option:
			#child.queue_free()
	check_comfirm_button_enabled()
	#if actor is CarrierActor:
		#sub_actors_container.show()
		#for child:BaseActor in carrier.list_carried_actors():
			#if child == actor:
				#continue
			#var option = premade_sub_actor_option.duplicate()
			#var portarit :TextureRect= option.get_node("PortraitBackground/PortraitTextureRect")
			#portarit.texture = child.get_small_icon()
			#var check_box = option.get_node("CheckBox")
			#sub_actor_check_boxes[child.Id] = check_box
			#sub_actors_options_container.add_child(option)
			#option.show()
	#else:
		#sub_actors_container.hide()

func check_comfirm_button_enabled():
	var should_be_disabled = false
	var selected_actor_ids = actor_buttons_control.get_select_deploy_actor_ids()
	if selected_actor_ids.size() == 0:
		should_be_disabled = true
	if !deployment_ui_state or !deployment_ui_state.deploying_position:
		should_be_disabled = true
	confirm_button.disabled = should_be_disabled
	
