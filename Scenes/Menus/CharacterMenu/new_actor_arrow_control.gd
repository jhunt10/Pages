class_name NewActorArrowControl
extends TextureRect

@export var flashing:bool
@export var flash_speed:float

var going_down

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if flashing:
		if not self.visible:
			self.show()
			self.self_modulate.a = 0
		var alpha = self.self_modulate.a
		if going_down:
			alpha -= flash_speed * delta
		else:
			alpha += flash_speed * delta
		if alpha < 0:
			alpha = 0
			going_down = false
		if alpha >= 1.1:
			alpha = 1.1
			going_down = true
		self.self_modulate.a = alpha
	elif self.visible:
		self.hide()
	pass
