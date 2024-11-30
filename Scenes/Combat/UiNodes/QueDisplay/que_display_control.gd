class_name QueDisplayControl
extends Control

const PADDING = 8

@export var portrait:TextureRect
@export var main_container:HBoxContainer
@export var slot_button_prefab:TextureButton
@export var slots_container:HBoxContainer
#@onready var que_path_arrow:Sprite2D = $QuePathArrow

@export var show_preview_movement:bool
@export var show_gaps:bool

var _actor:BaseActor
var _actor_node:ActorNode:
	get: return CombatRootControl.Instance.MapController.actor_nodes.get(_actor.Id)
var _slot_buttons = []
var _real_slots = []
var movement_preview_pos:MapPos
var _target_display_key
var _resize:bool = false
var _delayed_init = false

func _ready():
	slot_button_prefab.visible = false
	#if !show_preview_movement:
		#que_path_arrow.visible = false
	CombatRootControl.QueController.que_ordering_changed.connect(_build_slots)
	CombatRootControl.QueController.start_of_round.connect(_hide_preview)
	#CombatRootControl.QueController.end_of_round.connect(_show_preview_path)
	CombatRootControl.QueController.start_of_turn.connect(_set_action_highlight)
	CombatRootControl.QueController.end_of_turn.connect(_hide_action_highlight)
	
	if _delayed_init:
		portrait.texture = _actor.sprite.get_portrait_sprite()
		_build_slots()
		_sync()
	
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

func _sync():
	_sync_icons()
	if CombatRootControl.QueController.execution_state == CombatRootControl.QueController.ActionStates.Waiting:
		_preview_que_path()
	# Delete old target area display
	if _target_display_key:
		CombatRootControl.Instance.MapController.target_area_display.clear_display(_target_display_key)
	
	# Display last page's target area for mobile
	if MainRootNode.is_mobile and _actor.Que.real_que.size() > 0:
		var last_page:BaseAction = _actor.Que.real_que[-1]
		if last_page.has_preview_target():
			var target_parms = last_page.get_preview_target_params(_actor)
			if !target_parms:
				printerr("QueDisplayControl._sync: %s Failed to find preview TargetParams ." % [last_page.ActionKey])
			else:
				var preview_pos = _actor.Que.get_movement_preview_pos()
				var target_selection_data = TargetSelectionData.new(target_parms, 'Preview', _actor, CombatRootControl.Instance.GameState, [], preview_pos)
				_target_display_key = CombatRootControl.Instance.MapController.target_area_display.build_from_target_selection_data(target_selection_data)

func set_actor(actor:BaseActor):
	if _actor:
		if actor.Que.action_que_changed.is_connected(_sync):
			actor.Que.action_que_changed.disconnect(_sync)
		if actor.equipment_changed.is_connected(_sync):
			actor.equipment_changed.disconnect(_sync)
	_actor = actor
	actor.Que.action_que_changed.connect(_sync)
	actor.equipment_changed.connect(_sync)
	if portrait:
		portrait.texture = actor.sprite.get_portrait_sprite()
		_build_slots()
		_sync()
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
		new_button.name = "PageSlot" + str(index)
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
		if _real_slots.size() > index:
			var slot:QueDisplaySlot = _real_slots[index]
			slot.set_action(index, _actor, action)
			index += 1
		
	for n in range(index, _actor.Que.get_max_que_size()):
		if n < _real_slots.size():
			var slot:QueDisplaySlot = _real_slots[n]
			slot.set_action(n, _actor, null)
	
func _slot_pressed(index:int):
	_actor.Que.delete_at_index(index)

func _hide_preview():
	_actor_node.hide_path_arrow()
	if _target_display_key:
		CombatRootControl.Instance.MapController.target_area_display.clear_display(_target_display_key)

func _preview_que_path():
	if !_actor or !_actor_node:
		return
	#if not show_preview_movement or !que_path_arrow:
		#return
	var actor_pos = CombatRootControl.Instance.GameState.MapState.get_actor_pos(_actor)
	var preview_pos = _actor.Que.get_movement_preview_pos()
	if !preview_pos:
		_actor_node.hide_path_arrow()
		return
	if preview_pos == actor_pos:
		_actor_node.hide_path_arrow()
		return
		
	_actor_node.set_path_arrow_pos(preview_pos)
	movement_preview_pos = preview_pos
	_actor_node.show_path_arrow()
