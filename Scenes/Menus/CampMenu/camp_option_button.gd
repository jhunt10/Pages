@tool
class_name CampOptionButton
extends FitScaleLabel

@export var button:Button
@export var highlight:Node
@export var disabled:bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
	highlight.hide()
	if not disabled:
		button.mouse_entered.connect(highlight.show)
		button.mouse_exited.connect(highlight.hide)
	else:
		label.self_modulate = Color.DIM_GRAY
		
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	pass
