class_name PositionBoxDialogBlock
extends BaseDialogBlock

func set_block_data(parent, data):
	data['WaitForButton'] = false
	super(parent, data)

func do_thing():
	var position_name = _block_data.get('Position', null)
	var screen_size = get_viewport_rect().size
	var parent_size = _parent_dialog_control.dialog_box.size
	var new_pos = _parent_dialog_control._start_position
	if position_name == 'Reset':
		new_pos = _parent_dialog_control._start_position
	elif position_name == 'Top':
		new_pos = Vector2(screen_size.x / 2 - parent_size.x / 2, 0)
	elif position_name == 'Bottom':
		new_pos = Vector2(screen_size.x / 2 - parent_size.x / 2, screen_size.y - parent_size.y)
	else:
		printerr("PositionBoxDialogBlock: Unknown postion name '%s'. " % [position_name])
	print("Setting Position: Cur: %s | New: %s" % [_parent_dialog_control.position, new_pos] )
	_parent_dialog_control.dialog_box.position = new_pos
	self._finished = true
	self.finished.emit()
