class_name QueDisplaySlot
extends TextureButton

@onready var gap_texture:TextureRect = $GapTextureRect
@onready var icon:TextureRect = $Icon
@onready var highlight:TextureRect = $SlotHighlight
@onready var dead_icon:TextureRect = $DeadSlotIcon

var is_gap:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dead_icon.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func set_is_gap(val:bool):
	is_gap = val
	gap_texture.visible = is_gap
	if is_gap:
		icon.visible = false
		icon.texture = null
		
func set_action(index:int, actor:BaseActor, action:BaseAction):
	if action and not is_gap:
		icon.visible = true
		icon.texture = action.get_qued_icon(index, actor)
	else:
		icon.visible = false
		icon.texture = null
