class_name CameraLockControl
extends Control

@export var camera:MoveableCamera2D
@export var locked_icon:TextureRect
@export var unlocked_icon:TextureRect
@export var following_icon:TextureRect
@export var button:Button

var camera_locked:bool


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera_locked = camera.freeze or camera.locked_for_cut_scene
	if can_camera_move():
		locked_icon.hide()
		unlocked_icon.show()
	else:
		locked_icon.show()
		unlocked_icon.hide()
		
	pass # Replace with function body.

func can_camera_move()->bool:
	return not (camera.freeze or camera.following_actor_node or camera.auto_pan_start_pos or camera.locked_for_cut_scene)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if can_camera_move():
		camera_locked = false
		locked_icon.hide()
		unlocked_icon.show()
	else:
		camera_locked = true
		locked_icon.show()
		unlocked_icon.hide()
	if camera.following_actor_node:
		following_icon.show()
	else:
		following_icon.hide()
	pass
