class_name QueMiniSlotIcon
extends Control

@onready var background:TextureRect = $PageSlot
@onready var gap_icon:TextureRect = $GapTextureRect
@onready var page_icon:TextureRect = $Icon
@onready var highlight:TextureRect = $Highlight
@onready var dead_icon:TextureRect = $DeadIcon

var is_gap = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dead_icon.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_is_gap(val:bool):
	is_gap = val
	gap_icon.visible = is_gap
	if is_gap:
		set_action(null)
		
func set_action(action:BaseAction):
	if action and not is_gap:
		page_icon.visible = true
		page_icon.texture = action.get_small_page_icon()
	else:
		page_icon.visible = false
		page_icon.texture = null

func set_highlight(val:bool):
	highlight.visible = val

func mark_as_dead():
	dead_icon.visible = true
