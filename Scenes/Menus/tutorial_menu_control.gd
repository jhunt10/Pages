extends Control

@export var next_button:Button
@export var back_button:Button
@export var close_button:Button

@export var page_one:ColorRect
@export var page_two:ColorRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	page_one.visible = true
	page_two.visible = false
	next_button.visible = true
	back_button.visible = false
	next_button.pressed.connect(on_next)
	back_button.pressed.connect(on_back)
	close_button.pressed.connect(on_close)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_next():
	page_one.visible = false
	page_two.visible = true
	back_button.visible = true
	next_button.visible = false

func on_back():
	page_one.visible = true
	page_two.visible = false
	back_button.visible = false
	next_button.visible = true

func on_close():
	self.queue_free()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and (event as InputEventKey).keycode == KEY_ESCAPE and (event as InputEventKey).is_released():
		self.queue_free()
