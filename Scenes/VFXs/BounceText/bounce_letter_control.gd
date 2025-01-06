@tool
class_name BounceLetterControl
extends Label

@export var label:Label
@export var timer:float
@export var bounce_scale:float = 1
@export var speed_scale:float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta * PI * speed_scale
	if timer > 2 * PI:
		timer -= 2 * PI
	label.position.y = sin(timer) * bounce_scale
	pass

func set_letter(letter:String):
	self.text = letter
	label.text = letter
