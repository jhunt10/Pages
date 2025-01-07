@tool
class_name CampOptionButton
extends FitScaleLabel

@export var button:Button
@export var under_line:Node
@export var highlight:Node
@export var disabled:bool:
	set(val):
		disabled = val
		if label:
			if disabled:
				label.self_modulate = Color.DIM_GRAY
			else:
				label.self_modulate = Color("780000")
		

@export var is_highlighted:bool:
	set(val):
		is_highlighted = val
		if is_highlighted and highlight:
			highlight.show()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
	highlight.hide()
	under_line.hide()
	disabled = disabled
	button.mouse_entered.connect(_mouse_enter)
	button.mouse_exited.connect(_mouse_exit)
	button.button_down.connect(_button_down)
	button.button_up.connect(_button_up)

func _mouse_enter():
	if disabled: return
	under_line.show()
func _mouse_exit():
	if disabled: return
	under_line.hide()
func _button_down():
	if disabled: return
	highlight.show()
func _button_up():
	if disabled: return
	print("Button Up: %s" %[ self.text])
	if not is_highlighted:
		highlight.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	pass
