class_name PopUpBoxDialogBlock
extends BaseDialogBlock

func _init(parent, data):
	data['WaitForButton'] = false
	super(parent, data)

func do_thing():
	if _block_data.keys().has("Delete"):
		destory_popup()
	if _block_data.keys().has("Create"):
		create_popup()
	self._finished = true
	self.finished.emit()

func create_popup():
	var popup_key = _block_data.get("Create", null)
	var screen_size = _parent_dialog_control.get_viewport_rect().size
	var parent_size = _parent_dialog_control.dialog_box.size
	var popup_pos = null
	var popup_size = null
	var size = null
	
	var popup_rect_arr = _block_data.get("Rect", null)
	if popup_rect_arr:
		popup_pos = Vector2(popup_rect_arr[0], popup_rect_arr[1])
		popup_size = Vector2(popup_rect_arr[2], popup_rect_arr[3])
	
	var target_element_path = _block_data.get("TargetElement", null)
	if target_element_path:
		var target_element = null
		if _parent_dialog_control.scene_root:
			target_element = _parent_dialog_control.scene_root.get_node(target_element_path)
		if !target_element:
			printerr("PopUpDialogBlock: No Target Element found.")
		if target_element is Control:
			popup_pos = target_element.get_screen_position()
			popup_size = target_element.size
		else:
			printerr("Target Element is not a control")
		
	if popup_pos != null and popup_size != null:
		var popup_path = _block_data.get("PopupControlSript", null)
		if !popup_path:
			printerr("No PopupControlSript")
			return
		var popup = load(popup_path).instantiate()
		if popup_size.x > 0:
			popup.size = popup_size
		popup.set_dialog_block(self)
		_parent_dialog_control.add_popup(popup_key, popup, popup_pos)
	else:
		printerr("Failed to pop")
	

func destory_popup():
	var popup_key = _block_data.get("Delete", null)
	if popup_key:
		_parent_dialog_control.remove_popup(popup_key)
	
