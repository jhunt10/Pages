extends Node2D

@onready var que_controller:QueControllerNode = $"../QueController"
@onready var background = $NinePatchRect
@onready var slot_prefab:Sprite2D = $ActionSlotPrefab
@onready var slot_highlight:Sprite2D = $ActionHighlight
@onready var que_path_arrow:Sprite2D = $QuePathArrow

const ICON_WIDTH = 32
const ICON_HIGHT = 32
const ICON_BETWEEN_PADDING = 8
const TOPBOT_PADDING = 8
const SIDE_PADDING = 8

var action_que:ActionQue
var icons = []
var movement_preview_pos:MapPos

func _ready():
	que_controller.start_of_round.connect(_hide_preview_path)
	que_controller.end_of_round.connect(_show_preview_path)
	que_controller.start_of_turn.connect(_set_action_highlight)
	que_controller.end_of_turn.connect(_hide_action_highlight)
	
func set_action_que(que:ActionQue):
	action_que = que
	action_que.action_que_changed.connect(_sync_que)
	_build_icons()
	
func _set_action_highlight():
	var turn_index = que_controller.action_index
	var slot = icons[turn_index]
	remove_child(slot_highlight)
	add_child(slot_highlight)
	slot_highlight.position = slot.position
	slot_highlight.visible = true
	
func _hide_action_highlight():
	remove_child(slot_highlight)
	add_child(slot_highlight)
	slot_highlight.position = slot_prefab.position
	slot_highlight.visible = false

func _sync_que():
	_build_icons()
	_preview_que_path()
		
func _build_icons():
	# Delete existing icons
	while icons.size() > 0:
		icons[icons.size()-1].queue_free()
		icons.remove_at(icons.size()-1)
			
	var pos = Vector2(SIDE_PADDING, TOPBOT_PADDING)
	for i in range(action_que.que_size):
		var action = action_que.get_action_for_turn(i)
		var new_icon:Sprite2D = slot_prefab.duplicate()
		new_icon.position = Vector2(SIDE_PADDING 
			+ (ICON_WIDTH + ICON_BETWEEN_PADDING) * i
			, TOPBOT_PADDING)
		add_child(new_icon)
#			new_icon.button_down.connect(_button_pressed.bind(i))
		new_icon.visible = true
		
		if action:
			new_icon.texture = action.get_large_sprite()
		
		icons.append(new_icon)
		pos.x += ICON_WIDTH + ICON_BETWEEN_PADDING
		pos.y += ICON_HIGHT
			
	background.size.x = SIDE_PADDING + (ICON_WIDTH * action_que.que_size) + (ICON_BETWEEN_PADDING * (action_que.que_size - 1)) + SIDE_PADDING
	background.size.y = TOPBOT_PADDING + ICON_HIGHT + TOPBOT_PADDING

func _hide_preview_path():
	que_path_arrow.visible = false

func _show_preview_path():
	que_path_arrow.visible = true

func _preview_que_path():
	var preview_pos = action_que.get_movement_preview_pos()
	var local_map_pos = CombatRootControl.Instance.MapController.actor_tile_map.map_to_local(Vector2i(preview_pos.x, preview_pos.y))
	var global_map_pos = CombatRootControl.Instance.MapController.actor_tile_map.global_position + local_map_pos
	que_path_arrow.global_position = global_map_pos
	if preview_pos.dir == 0: que_path_arrow.set_rotation_degrees(0) 
	if preview_pos.dir == 1: que_path_arrow.set_rotation_degrees(90) 
	if preview_pos.dir == 2: que_path_arrow.set_rotation_degrees(180) 
	if preview_pos.dir == 3: que_path_arrow.set_rotation_degrees(270) 
	movement_preview_pos = preview_pos
	
