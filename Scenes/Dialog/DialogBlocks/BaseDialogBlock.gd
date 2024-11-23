class_name BaseDialogBlock
extends BoxContainer

signal finished

const LETTER_DELAY:float = 0.03
const LINE_DELAY:float = 0.3

var _parent_dialog_control:DialogControl
var _block_data:Dictionary
var _delay_timer:float = 0
var _finished:bool = false

func set_block_data(parent, data):
	self._parent_dialog_control = parent
	self._block_data = data

func start():
	do_thing()

func _process(delta: float) -> void:
	if self._finished:
		return
		
	if !_parent_dialog_control or !_block_data:
		return
		
	if _parent_dialog_control.waiting_for_button:
		return
	
	if _delay_timer > 0:
		_delay_timer -= delta
		if _delay_timer <= 0:
			do_thing()

func do_thing():
	pass

func skip():
	if !self._finished:
		on_skip()

func on_skip():
	pass

func archive():
	self.queue_free()
	pass
	#self.custom_minimum_size = Vector2.ZERO
	#self.size = Vector2.ZERO
	#_parent_dialog_control.scroll_to_bottom()
