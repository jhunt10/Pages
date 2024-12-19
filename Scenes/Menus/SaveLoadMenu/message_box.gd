class_name SaveLoadMessageBox
extends NinePatchRect

signal message_done

@export var delay_time:float
@export var message_label:Label
var _timer:float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func show_message(message:String, delay:float):
	message_label.text = message
	delay_time = delay
	_timer = delay_time
	self.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _timer > 0:
		_timer -= delta
		if _timer <= 0:
			_timer = 0
			message_done.emit()
	pass
