class_name QueMiniSlotIcon
extends Control

@export var background:TextureRect
@export var gap_icon:TextureRect
@export var _page_icon:TextureRect
@export var highlight:TextureRect
@export var dead_icon:TextureRect
@export var unknown_icon:TextureRect

var is_gap = true
@export var acttion_key:String

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
		_page_icon.visible = false
		#page_icon.texture = null
		unknown_icon.visible = false
		
func set_action(index:int, actor:BaseActor, action:BaseAction):
	if action:
		#print("QueMiniSlotIcon: Setting Action: %s | %s" % [action.ActionKey, index])
		acttion_key = action.ActionKey
		_page_icon.show()
		_page_icon.texture = action.get_qued_icon(index, actor)
	else:
		#print("QueMiniSlotIcon: Setting Action: 'NULL' | %s" % [index])
		acttion_key = 'Null'
		_page_icon.visible = false
		_page_icon.texture = null

func set_highlight(val:bool):
	highlight.visible = val

func mark_as_dead():
	dead_icon.visible = true
