class_name QueDisplayControl
extends Control

const PADDING = 8

@onready var main_container:HBoxContainer = $HBoxContainer
@onready var que_controller:QueControllerNode = $"../../QueController"
@onready var slot_button_prefab:TextureButton = $HBoxContainer/PageSlotButtonPrefab
@onready var que_path_arrow:Sprite2D = $QuePathArrow

var _actor:BaseActor
var _slot_buttons = []
var movement_preview_pos:MapPos
var _resize:bool = false

func _ready():
	slot_button_prefab.visible = false
	que_controller.start_of_round.connect(_hide_preview_path)
	que_controller.end_of_round.connect(_show_preview_path)
	que_controller.start_of_turn.connect(_set_action_highlight)
	que_controller.end_of_turn.connect(_hide_action_highlight)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if _resize:
		self.size = Vector2i(main_container.size.x + (2 * PADDING),
							main_container.size.y + (2 * PADDING))
		_resize = false

func _set_action_highlight():
	_hide_action_highlight()
	var turn_index = que_controller.action_index
	var slot = _slot_buttons[turn_index]
	slot.highlight.visible = true
	
func _hide_action_highlight():
	for slot in _slot_buttons:
		slot.highlight.visible = false

func _sync_que():
	_sync_icons()
	_preview_que_path()

func set_actor(actor:BaseActor):
	_actor = actor
	actor.Que.action_que_changed.connect(_sync_que)
	_build_slots()
	_sync_que()
	
func _build_slots():
	if _slot_buttons.size() > 0:
		for slot:TextureButton in _slot_buttons:
			slot.queue_free()
		_slot_buttons.clear()
	for index in range(_actor.Que.que_size):
		var new_button:TextureButton = slot_button_prefab.duplicate()
		slot_button_prefab.get_parent().add_child(new_button)
		new_button.icon.texture = null
		new_button.icon.visible = false
		new_button.visible = true
		new_button.pressed.connect(_slot_pressed.bind(index))
		_slot_buttons.append(new_button)
	_resize = true

func _sync_icons():
	var index = 0
	for action:BaseAction in _actor.Que.list_qued_actions():
		var slot:QueDisplaySlot = _slot_buttons[index]
		slot.set_action(action)
		index += 1
		
	for n in range(index, _actor.Que.que_size):
		var slot:QueDisplaySlot = _slot_buttons[n]
		slot.set_action(null)
	
func _slot_pressed(index:int):
	_actor.Que.delete_at_index(index)

func _hide_preview_path():
	que_path_arrow.visible = false

func _show_preview_path():
	que_path_arrow.visible = true

func _preview_que_path():
	var preview_pos = _actor.Que.get_movement_preview_pos()
	var local_map_pos = CombatRootControl.Instance.MapController.actor_tile_map.map_to_local(Vector2i(preview_pos.x, preview_pos.y))
	var global_map_pos = CombatRootControl.Instance.MapController.actor_tile_map.global_position + local_map_pos
	que_path_arrow.global_position = global_map_pos
	if preview_pos.dir == 0: que_path_arrow.set_rotation_degrees(0) 
	if preview_pos.dir == 1: que_path_arrow.set_rotation_degrees(90) 
	if preview_pos.dir == 2: que_path_arrow.set_rotation_degrees(180) 
	if preview_pos.dir == 3: que_path_arrow.set_rotation_degrees(270) 
	movement_preview_pos = preview_pos
