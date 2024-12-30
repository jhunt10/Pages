class_name DialogPopUpController
extends Control

@export var parent_dialog_controller:DialogController
var _popups:Dictionary = {}

## Returns true if block should be waitied on
func handle_pop_up(block_data:Dictionary)->bool:
	var block_type_str = block_data.get("BlockType", '')
	var block_type = DialogController.BlockTypes.get(block_type_str)
	if block_type == null:
		printerr("Unknown DialogBox PopUp BlockType: '%s'." % [block_type_str])
		return false
	if block_type == DialogController.BlockTypes.SpeechBubble:
		return create_speech_bubble(block_data)
	
	var destroy_id  = block_data.get("Destroy", null)
	if destroy_id and _popups.has(destroy_id):
		_popups[destroy_id].queue_free()
		_popups.erase(destroy_id)
	
	var create_id = block_data.get("Create")
	if create_id:
		return create_highlight(block_data)
	return false

## Returns true if block should be waitied on
func create_highlight(block_data:Dictionary)->bool:
	var popup_key = block_data.get("Create", null)
	var screen_size = parent_dialog_controller.get_viewport_rect().size
	var popup_pos = null
	var popup_size = null
	var size = null
	
	var popup_rect_arr = block_data.get("Rect", null)
	if popup_rect_arr:
		popup_pos = Vector2(popup_rect_arr[0], popup_rect_arr[1])
		popup_size = Vector2(popup_rect_arr[2], popup_rect_arr[3])
	
	var target_element_path = block_data.get("TargetElement", null)
	if target_element_path:
		var target_element = null
		if parent_dialog_controller.scene_root:
			target_element = parent_dialog_controller.scene_root.get_node(target_element_path)
		if !target_element:
			printerr("PopUpDialogBlock: No Target Element found.")
		if target_element is Control:
			popup_pos = target_element.get_screen_position()
			popup_size = target_element.size
		else:
			printerr("Target Element is not a control")
		
	if popup_pos != null and popup_size != null:
		var popup_path = block_data.get("PopupControlSript", null)
		if !popup_path:
			printerr("No PopupControlSript")
			return false
		var popup = load(popup_path).instantiate()
		if popup_size.x > 0:
			popup.size = popup_size
		popup.set_dialog_block(self)
		self.add_child(popup)
		_popups[popup_key] = popup
		popup.position = popup_pos
	else:
		printerr("Failed to pop")
	return false


## Returns true if block should be waitied on
func create_speech_bubble(block_data:Dictionary)->bool:
	var pop_up_key = block_data.get("PopUpKey", null)
	if !pop_up_key:
		printerr("DialogController: No 'PopUpKey' provided on SpeechBubble block.")
		return false
	var action = block_data.get("Action", null)
	if action != "Create" and action != "Destroy":
		printerr("DialogController: Unknown SpeechBubble Action: %s." % [action])
		return false
	if action == "Destroy":
		var pop_up = _popups.get(pop_up_key, null)
		if pop_up and pop_up is SpeachBubbleVfxNode:
			(pop_up as SpeachBubbleVfxNode).showing = false
			_popups.erase(pop_up_key)
	if action == "Create":
		if _popups.has(pop_up_key):
			printerr("DialogController: SpeechBubble '%s' already exists" % [pop_up_key])
			return false
			
		var display_text = block_data.get("Text", "null")
		var target_actor_id = block_data.get("TargetActorId", null)
		if !target_actor_id:
			printerr("DialogController: No 'TargetActorId' provided on SpeechBubble block.")
			return false
		var actor_node = CombatRootControl.get_actor_node(target_actor_id)
		if !actor_node:
			printerr("DialogController: SpeechBubble failed to find actor_node for Target Actor: %s" %[target_actor_id])
			return false
		
		var new_bubble:SpeachBubbleVfxNode = load("res://Scenes/VFXs/SpeachBubble/speach_bubble_vfx_node.tscn").instantiate()
		actor_node.vfx_holder.add_child(new_bubble)
		new_bubble.display_text = display_text
		new_bubble.showing = true
		new_bubble.position = Vector2(8,-21)
		_popups[pop_up_key] = new_bubble
		if block_data.get("WaitToFinish", false):
			new_bubble.finished_showing.connect(parent_dialog_controller._on_popup_finished.bind(pop_up_key))
			parent_dialog_controller._block_states[pop_up_key] = DialogController.BlockStates.Playing
			return true
	return false
		
