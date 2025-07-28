class_name QueCollection_QueDisplayContainer
extends BoxContainer

const LOGGING = false
const PADDING = 8

@export var portrait:TextureRect
@export var slot_button_prefab:QueMiniSlotIcon
@export var slots_container:HBoxContainer
@export var name_label:Label
var is_ai_actor:bool

func load_stuff():
	portrait = $PortraitTextureRect
	slot_button_prefab = $PageSlotPrefab
	slots_container = $SlotsContainer

var _actor:BaseActor
var _slots = []
var movement_preview_pos:MapPos
var _delayed_init = false

func _ready():
	if Engine.is_editor_hint():
		return
	slot_button_prefab.visible = false
	CombatRootControl.QueController.que_ordering_changed.connect(_build_slots)
	CombatRootControl.QueController.start_of_turn.connect(_set_action_highlight)
	CombatRootControl.QueController.end_of_round.connect(hide_all_highlights)
	
	if _delayed_init:
		portrait.texture = _actor.sprite.get_portrait_sprite()
		_build_slots()
		_sync_que()
		
func _set_action_highlight():
	var turn_index = CombatRootControl.QueController.action_index
	for index in range(_slots.size()):
		var slot:QueMiniSlotIcon = _slots[index]
		slot.set_highlight(index == turn_index)
func hide_all_highlights():
	for slot:QueMiniSlotIcon in _slots:
		slot.set_highlight(false)
		
func _sync_que():
	_sync_icons()

func set_actor(actor:BaseActor):
	_actor = actor
	actor.Que.action_que_changed.connect(_sync_que)
	is_ai_actor = !actor.is_player
	if portrait:
		portrait.texture = actor.sprite.get_portrait_sprite()
		_build_slots()
		_sync_que()
	else:
		_delayed_init = true

func show_ai_slots(show:bool):
	if not is_ai_actor:
		return
	#print("Hiding Ai slots for : " + _actor.Id)
	for slot:QueMiniSlotIcon in _slots:
		if not slot.is_gap:
			if show:
				slot.unknown_icon.show()
			else:
				slot.unknown_icon.hide()

func mark_as_dead():
	for slot:QueMiniSlotIcon in _slots:
		slot.mark_as_dead()

func _build_slots():
	#print("Build Slots")
	if not _actor:
		return
	if !slot_button_prefab:
		load_stuff()
	for child in _slots:
		child.queue_free()
	_slots.clear()
	for index in range(CombatRootControl.QueController.max_que_size):
		var is_gap = _actor.Que.is_turn_gap(index)
		var new_button:QueMiniSlotIcon = slot_button_prefab.duplicate()
		new_button.visible = true
		slots_container.add_child(new_button)
		new_button.set_is_gap(is_gap)
		_slots.append(new_button)
	name_label.text = _actor.Id
	if not _actor.is_player:
		show_ai_slots(false)

func _sync_icons():
	if LOGGING: print("\nSync Icons for " + _actor.ActorKey + " " + self.name)
	var index = 0
	for action:PageItemAction in _actor.Que.list_qued_actions():
		if _slots.size() <= index:
			break
		var slot:QueMiniSlotIcon = _slots[index]
		while slot and slot.is_gap:
			index += 1
			if index < _slots.size():
				slot = _slots[index]
			else:
				slot = null
		if slot:
			slot.set_action(index, _actor, action)
		if LOGGING: print("Set SLot Page: %s | %s " % [index, action.ActionKey])
		index += 1
		
	for n in range(index, _slots.size()+1):
		if n < _slots.size():
			if LOGGING: print("Set SLot Page: %s | NULL " % [index])
			var slot:QueMiniSlotIcon = _slots[n]
			slot.set_action(n, _actor, null)
	if LOGGING: print("\n")
