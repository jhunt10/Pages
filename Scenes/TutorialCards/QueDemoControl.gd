extends Control

@export var animation:AnimationPlayer
@export var grid:TextureRect
@export var play_button:Button

var played_once = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation.animation_finished.connect(_on_animation_finish)
	play_button.pressed.connect(_start_pressed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _start_pressed():
	if animation.is_playing():
		return
	animation.play("QueDemoAniation")
	if played_once:
		grid.rotation_degrees += 90
	play_button.hide()

func _on_animation_finish(animation_name):
	if animation_name == "QueDemoAniation":
		played_once = true
		play_button.show()
