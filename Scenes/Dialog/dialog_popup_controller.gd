class_name DialogPopUpController
extends Control

enum PopUpTypes { SpeechBubble, Highlight, TutorialCard}

@export var parent_dialog_controller:DialogController
var _popups:Dictionary = {}

## Returns true if block should be waitied on
func handle_pop_up(block_data:Dictionary)->bool:
	var delete_id  = block_data.get("Delete", null)
	if delete_id and _popups.has(delete_id):
		var pop_up = _popups[delete_id]
		if pop_up is SpeachBubbleVfxNode:
			(pop_up as SpeachBubbleVfxNode).showing = false
		else:
			pop_up.queue_free()
		_popups.erase(delete_id)
	
	var create_id = block_data.get("Create")
	if not create_id:
		return false
	
	var popup_type_str = block_data.get("PopUpType", "")
	var popup_type = PopUpTypes.get(popup_type_str)
	if popup_type == null:
		printerr("Unknown PopUpType: '%s'." % [popup_type_str])
		return false
	
	#----------------------------------
	#         Speech Bubble
	# Options:
	# 	 "WaitToFinish": Bool(false): Add "[PopUp_Id]" to list of block states
	# 	 "TargetActorId": String: Actor to place speech bubble on
	# 	 "Text": String: Text to be displayed in speech bubble
	#----------------------------------
	if popup_type == PopUpTypes.SpeechBubble:
		return create_speech_bubble(block_data)
	
	if popup_type == PopUpTypes.Highlight:
		return create_highlight(block_data)
	
	if popup_type == PopUpTypes.TutorialCard:
		return create_tutorial_card(block_data)
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
			var padding = block_data.get("Padding", [0,0,0,0])
			popup_pos.x += padding[0]
			popup_pos.y += padding[2]
			popup_size.x += padding[1] - padding[0]
			popup_size.y += padding[3] - padding[2]
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
		popup.set_dialog_block(block_data)
		self.add_child(popup)
		_popups[popup_key] = popup
		popup.position = popup_pos
		if block_data.get("WaitToBeClicked", false):
			parent_dialog_controller._block_states[popup_key] = DialogController.BlockStates.Playing
			popup.button.pressed.connect(parent_dialog_controller._on_popup_finished.bind(popup_key))
			return true
	else:
		printerr("Failed to pop")
	return false

## Returns true if block should be waitied on
func create_speech_bubble(block_data:Dictionary)->bool:
	var pop_up_key = block_data.get("Create", null)
	if !pop_up_key:
		printerr("DialogController: No 'PopUpKey' provided on SpeechBubble block.")
		return false
	if _popups.has(pop_up_key):
		printerr("DialogController: SpeechBubble '%s' already exists" % [pop_up_key])
		return false
		
	var target_actor_id = block_data.get("TargetActorId", null)
	if !target_actor_id:
		printerr("DialogController: No 'TargetActorId' provided on SpeechBubble block.")
		return false
	var actor_node = CombatRootControl.get_actor_node(target_actor_id)
	if !actor_node:
		printerr("DialogController: SpeechBubble failed to find actor_node for Target Actor: %s" %[target_actor_id])
		return false
	
	var new_bubble:SpeachBubbleVfxNode = load("res://Scenes/VFXs/SpeachBubble/speach_bubble_vfx_node.tscn").instantiate()
	var grow_direction = block_data.get("GrowDirection", "Center")
	var offset = block_data.get("Offset", [0,-8])
	
	actor_node.vfx_holder.add_child(new_bubble)
	new_bubble.set_block_data(block_data)
	new_bubble.showing = true
	_popups[pop_up_key] = new_bubble
	if block_data.get("WaitToFinish", false):
		new_bubble.finished_showing.connect(parent_dialog_controller._on_popup_finished.bind(pop_up_key))
		parent_dialog_controller._block_states[pop_up_key] = DialogController.BlockStates.Playing
		return true
	return false
		
func create_tutorial_card(block_data):
	var pop_up_key = block_data.get("Create", null)
	if !pop_up_key:
		printerr("DialogController: No 'PopUpKey' provided on SpeechBubble block.")
		return false
	var card_list = block_data.get("Cards", [])
	if card_list.size() == 0:
		return false
	var new_cards:TutorialCardsController = load("res://Scenes/TutorialCards/tutorial_cards.tscn").instantiate()
	parent_dialog_controller.add_child(new_cards)
	new_cards.card_list = card_list
	new_cards.card_index = block_data.get("Index", 0)
	new_cards.closed.connect(parent_dialog_controller._on_popup_finished.bind(pop_up_key))
	parent_dialog_controller._block_states[pop_up_key] = DialogController.BlockStates.Playing
	return true
