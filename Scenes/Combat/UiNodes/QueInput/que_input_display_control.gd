class_name QueInputDisplayControl
extends PanelContainer

const PADDING = 8

@export var portrait:TextureRect
@export var premade_que_button:QueDisplayButton
@export var slots_container:HBoxContainer
@export var show_preview_movement:bool
@export var show_gaps:bool

var _actor:BaseActor
var _actor_node:BaseActorNode:
	get: return CombatRootControl.Instance.MapController.actor_nodes.get(_actor.Id)
var _slot_buttons = []
var _real_slots = []
var movement_preview_pos:MapPos
var _target_display_key
var _delayed_init = false

func _ready():
	if premade_que_button:
		premade_que_button.visible = false
	CombatRootControl.QueController.que_ordering_changed.connect(_build_slots)
	CombatRootControl.QueController.start_of_round.connect(_hide_preview)
	
	if _delayed_init:
		portrait.texture = _actor.sprite.get_portrait_sprite()
		_build_slots()
		_sync()

var last_seen_max_que
func _sync():
	if _actor:
		var que_size = _actor.Que.get_max_que_size()
		if que_size != last_seen_max_que:
			_build_slots()
	_sync_icons()
	if CombatRootControl.QueController.execution_state == CombatRootControl.QueController.ActionStates.Waiting:
		movement_preview_pos = _actor.Que.get_movement_preview_final_pos()
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
		_build_slots()
		_sync()
	else:
		_delayed_init = true

func mark_as_dead():
	for slot:QueDisplayButton in _slot_buttons:
		slot.dead_icon.visible = true

func _build_slots():
	if not _actor or not premade_que_button:
		last_seen_max_que = 0
		return
	last_seen_max_que = _actor.Que.get_max_que_size()
	for child in slots_container.get_children():
		if child != premade_que_button:
			child.queue_free()
	_slot_buttons.clear()
	_real_slots.clear()
	for index in range(CombatRootControl.QueController.max_que_size):
		var is_gap = _actor.Que.is_turn_gap(index)
		var new_button:QueDisplayButton = premade_que_button.duplicate()
		if not is_gap or show_gaps:
			new_button.visible = true
		new_button.name = "PageSlot" + str(index)
		slots_container.add_child(new_button)
		new_button.set_is_gap(is_gap)
		new_button.button.pressed.connect(_slot_pressed.bind(index))
		_slot_buttons.append(new_button)
		if not is_gap:
			_real_slots.append(new_button)
	_sync_icons()

func _sync_icons():
	var index = 0
	for action:PageItemAction in _actor.Que.list_qued_actions(false):
		if _real_slots.size() > index:
			var slot:QueDisplayButton = _real_slots[index]
			var turn_index = _actor.Que.que_index_to_turn_index(index)
			slot.set_action(turn_index, _actor, action)
			index += 1
		
	for n in range(index, _actor.Que.get_max_que_size()):
		if n < _real_slots.size():
			var slot:QueDisplayButton = _real_slots[n]
			slot.set_action(n, _actor, null)
	
func _slot_pressed(index:int):
	var action = _actor.Que.get_action_for_turn(index)
	if action: 
		if action.ActionKey == "WaitToBeDeployed_ActionPage" or action.ActionKey == "BeDeployed_ActionPage":
			return
	_actor.Que.delete_at_turn_index(index)

func _hide_preview():
	if _target_display_key:
		CombatRootControl.Instance.MapController.target_area_display.clear_display(_target_display_key)
