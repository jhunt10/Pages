class_name QueDisplayControl
extends Control

const PADDING = 8

@export var portrait:TextureRect
@export var main_container:HBoxContainer
@export var premade_que_button:QueDisplaySlot
@export var slots_container:HBoxContainer
@export var npc_index_label:Label
#@onready var que_path_arrow:Sprite2D = $QuePathArrow

@export var show_preview_movement:bool
@export var show_gaps:bool

var _actor:BaseActor
var _actor_node:BaseActorNode:
	get: return CombatRootControl.Instance.MapController.actor_nodes.get(_actor.Id)
var _slot_buttons = []
var _real_slots = []
var movement_preview_pos:MapPos
var _target_display_key
var _resize:bool = false
var _delayed_init = false

func _ready():
	if premade_que_button:
		premade_que_button.visible = false
	CombatRootControl.QueController.que_ordering_changed.connect(_build_slots)
	CombatRootControl.QueController.start_of_round.connect(_hide_preview)
	
	if _delayed_init:
		portrait.texture = _actor.sprite.get_portrait_sprite()
		npc_index_label.text = _actor.get_npc_index_str()
		_build_slots()
		_sync()
	
func _process(_delta: float) -> void:
	if _resize:
		self.size = Vector2i(main_container.size.x + (2 * PADDING),
							main_container.size.y + (2 * PADDING))
		_resize = false

func _sync():
	_sync_icons()
	if CombatRootControl.QueController.execution_state == CombatRootControl.QueController.ActionStates.Waiting:
		preview_que_path()
	# Delete old target area display
	if _target_display_key:
		CombatRootControl.Instance.MapController.target_area_display.clear_display(_target_display_key)
		_target_display_key = null

func clear_preview():
	if _target_display_key:
		CombatRootControl.Instance.MapController.target_area_display.clear_display(_target_display_key)
		_target_display_key = null

func set_actor(actor:BaseActor):
	if _actor:
		if actor.Que.action_que_changed.is_connected(_sync):
			actor.Que.action_que_changed.disconnect(_sync)
	_actor = actor
	actor.Que.action_que_changed.connect(_sync)
	if portrait:
		portrait.texture = actor.sprite.get_portrait_sprite()
		npc_index_label.text = _actor.get_npc_index_str()
		_build_slots()
		_sync()
	else:
		_delayed_init = true

func mark_as_dead():
	for slot:QueDisplaySlot in _slot_buttons:
		slot.dead_icon.visible = true

func _build_slots():
	if not _actor or not premade_que_button:
		return
	for child in slots_container.get_children():
		if child != premade_que_button:
			child.queue_free()
	_slot_buttons.clear()
	_real_slots.clear()
	for index in range(CombatRootControl.QueController.max_que_size):
		var is_gap = _actor.Que.is_turn_gap(index)
		var new_button:QueDisplaySlot = premade_que_button.duplicate()
		if not is_gap or show_gaps:
			new_button.visible = true
		new_button.name = "PageSlot" + str(index)
		slots_container.add_child(new_button)
		new_button.set_is_gap(is_gap)
		_slot_buttons.append(new_button)
		if not is_gap:
			_real_slots.append(new_button)
	_resize = true
	_sync_icons()

func _sync_icons():
	var index = 0
	for action:PageItemAction in _actor.Que.list_qued_actions():
		if _real_slots.size() > index:
			var slot:QueDisplaySlot = _real_slots[index]
			slot.set_action(index, _actor, action)
			index += 1
		
	for n in range(index, _actor.Que.get_max_que_size()):
		if n < _real_slots.size():
			var slot:QueDisplaySlot = _real_slots[n]
			slot.set_action(n, _actor, null)

func _hide_preview():
	if _target_display_key:
		CombatRootControl.Instance.MapController.target_area_display.clear_display(_target_display_key)

func preview_que_path(add_movement:MapPos=null):
	if !_actor or !_actor_node:
		return
	var actor_pos = CombatRootControl.Instance.GameState.get_actor_pos(_actor)
	var preview_pos = _actor.Que.get_movement_preview_pos()
	if add_movement:
		preview_pos = preview_pos.apply_relative_pos(add_movement)
	if !preview_pos:
		_actor_node.hide_path_arrow()
		return
	if preview_pos == actor_pos:
		_actor_node.hide_path_arrow()
		return
		
	_actor_node.set_path_arrow_pos(preview_pos)
	movement_preview_pos = preview_pos
	_actor_node.show_path_arrow()
