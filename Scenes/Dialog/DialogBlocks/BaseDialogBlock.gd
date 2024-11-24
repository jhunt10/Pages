class_name BaseDialogBlock

signal finished

const LETTER_DELAY:float = 0.03
const LINE_DELAY:float = 0.3

var _parent_dialog_control:DialogControl
var _block_data:Dictionary
var _finished:bool = false
var is_finished:bool:
	get: return _finished

func _init(parent, data)->void:
	self._parent_dialog_control = parent
	self._block_data = data

func get_block_data()->Dictionary:
	return _block_data

func start():
	do_thing()

func update(delta: float) -> void:
	pass

func do_thing():
	pass

func skip():
	if self._finished:
		return
	if try_skip():
		self.finish()

## Returns true if skipping caused the block to finish 
func try_skip()->bool:
	return true

func finish():
	if _finished:
		return
	_finished = true
	self.finished.emit()

func get_next_block_tag():
	return _block_data.get("NextBlockTag")

func delete():
	pass
