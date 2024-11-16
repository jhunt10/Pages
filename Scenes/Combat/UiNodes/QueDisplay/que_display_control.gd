class_name QueDisplayControl
extends Control

const PADDING = 8

@onready var portrait:TextureRect = $HBoxContainer/PortraitTextureRect
@onready var main_container:HBoxContainer = $HBoxContainer
@onready var slot_button_prefab:TextureButton = $HBoxContainer/PageSlotButtonPrefab
@onready var slots_container:HBoxContainer = $HBoxContainer/SlotsContainer
@onready var que_path_arrow:Sprite2D = $QuePathArrow

@export var show_preview_movement:bool
@export var show_gaps:bool

var _actor:BaseActor
var _slot_buttons = []
var _real_slots = []
var movement_preview_pos:MapPos
var _resize:bool = false
var _delayed_init = false

func _ready():
	slot_button_prefab.visible = false
	if !show_preview_movement:
		que_path_arrow.visible = false
	CombatRootControl.QueController.que_ordering_changed.connect(_build_slots)
	CombatRootControl.QueController.start_of_round.connect(_hide_preview_path)
	CombatRootControl.QueController.end_of_round.connect(_show_preview_path)
	CombatRootControl.QueController.start_of_turn.connect(_set_action_highlight)
	CombatRootControl.QueController.end_of_turn.connect(_hide_action_highlight)
	
	if _delayed_init:
		portrait.texture = _actor.get_portrait_sprite()
		_build_slots()
		_sync_que()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if _resize:
		self.size = Vector2i(main_container.size.x + (2 * PADDING),
							main_container.size.y + (2 * PADDING))
		_resize = false

func _set_action_highlight():
	_hide_action_highlight()
	var turn_index = CombatRootControl.QueController.action_index
	if turn_index < _slot_buttons.size():
		var slot = _slot_buttons[turn_index]
		slot.highlight.visible = true
	
func _hide_action_highlight():
	for slot in _slot_buttons:
		slot.highlight.visible = false

func _sync_que():
	_sync_icons()
	_preview_que_path()

func set_actor(actor:BaseActor):
	if _actor:
		if actor.Que.action_que_changed.is_connected(_sync_que):
			actor.Que.action_que_changed.disconnect(_sync_que)
		if actor.equipment_changed.is_connected(_sync_que):
			actor.equipment_changed.disconnect(_sync_que)
	_actor = actor
	actor.Que.action_que_changed.connect(_sync_que)
	actor.equipment_changed.connect(_sync_que)
	if portrait:
		portrait.texture = actor.get_portrait_sprite()
		_build_slots()
		_sync_que()
	else:
		_delayed_init = true

func mark_as_dead():
	for slot:QueDisplaySlot in _slot_buttons:
		slot.dead_icon.visible = true

func _build_slots():
	if not _actor:
		return
	for child in slots_container.get_children():
		child.queue_free()
	_slot_buttons.clear()
	_real_slots.clear()
	for index in range(CombatRootControl.QueController.max_que_size):
		var is_gap = _actor.Que.is_turn_gap(index)
		var new_button:QueDisplaySlot = slot_button_prefab.duplicate()
		if not is_gap or show_gaps:
			new_button.visible = true
		slots_container.add_child(new_button)
		new_button.set_is_gap(is_gap)
		new_button.pressed.connect(_slot_pressed.bind(index))
		_slot_buttons.append(new_button)
		if not is_gap:
			_real_slots.append(new_button)
	_resize = true

func _sync_icons():
	var index = 0
	for action:BaseAction in _actor.Que.list_qued_actions():
		var slot:QueDisplaySlot = _real_slots[index]
		slot.set_action(_actor, action)
		index += 1
		
	for n in range(index, _actor.Que.get_max_que_size()):
		if n < _real_slots.size():
			var slot:QueDisplaySlot = _real_slots[n]
			slot.set_action(_actor, null)
	
func _slot_pressed(index:int):
	_actor.Que.delete_at_index(index)

func _hide_preview_path():
	que_path_arrow.visible = false

func _show_preview_path():
	que_path_arrow.visible = show_preview_movement

func _preview_que_path():
	if not show_preview_movement or !que_path_arrow:
		return
	var preview_pos = _actor.Que.get_movement_preview_pos()
	if !preview_pos:
		return
	var local_map_pos = CombatRootControl.Instance.MapController.actor_tile_map.map_to_local(Vector2i(preview_pos.x, preview_pos.y))
	var global_map_pos = CombatRootControl.Instance.MapController.actor_tile_map.global_position + local_map_pos
	que_path_arrow.global_position = global_map_pos
	que_path_arrow.visible = true
	if preview_pos.dir == 0: que_path_arrow.set_rotation_degrees(0) 
	if preview_pos.dir == 1: que_path_arrow.set_rotation_degrees(90) 
	if preview_pos.dir == 2: que_path_arrow.set_rotation_degrees(180) 
	if preview_pos.dir == 3: que_path_arrow.set_rotation_degrees(270) 
	movement_preview_pos = preview_pos
