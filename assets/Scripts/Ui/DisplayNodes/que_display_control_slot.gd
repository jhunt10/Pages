class_name QueDisplaySlot
extends TextureButton

@onready var icon:TextureRect = $Icon
@onready var highlight:TextureRect = $SlotHighlight

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_action(action:BaseAction):
	if action:
		icon.visible = true
		icon.texture = action.get_small_sprite()
	else:
		icon.visible = false
		icon.texture = null
