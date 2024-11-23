class_name PopUpBoxDialogBlock
extends BaseDialogBlock

func set_block_data(parent, data):
	data['WaitForButton'] = false
	super(parent, data)

func do_thing():
	print("Doing Pop Up Thing")
	if _block_data.get("Destory", false):
		destory_popup()
	if _block_data.keys().has("Create"):
		create_popup()
	self._finished = true
	self.finished.emit()

func create_popup():
	print("### Creating Pop Up")
	var popup_key = _block_data.get("Create", null)
	var target_element_path = _block_data.get("TargetElement", null)
	if !target_element_path:
		return
	
	var target_element = null
	if _parent_dialog_control.scene_root:
		target_element = _parent_dialog_control.scene_root.get_node(target_element_path)
	if !target_element:
		printerr("PopUpDialogBlock: No Target Element found.")
		return
		
	var screen_size = get_viewport_rect().size
	var parent_size = _parent_dialog_control.dialog_box.size
	var popup_pos = Vector2.ZERO
	
	var popup = ColorRect.new()
	popup.color = Color("ffffad65")
	
	if (target_element as Control):
		popup.size = (target_element as Control).size
		popup_pos = target_element.get_screen_position()
	else:
		printerr("Target Element is not a control")
	_parent_dialog_control.add_popup(popup_key, popup, popup_pos)
	

func destory_popup():
	print("### Destorying Pop Up")
	var popup_key = _block_data.get("Destory", null)
	if popup_key:
		_parent_dialog_control.remove_popup(popup_key)
	
