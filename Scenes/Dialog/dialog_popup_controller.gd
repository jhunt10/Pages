class_name DialogPopUpController
extends Control

enum PopUpTypes {LocationTime, SpeechBubble, Highlight, TutorialCard, ClickDrag, SpotLight}

@export var parent_dialog_controller:DialogController
var _popups:Dictionary = {}

func clear_popups():
	for popup in _popups.values():
		popup.queue_free()
	_popups.clear()

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
	
	if popup_type == PopUpTypes.LocationTime:
		return create_time_location_pop_up(block_data)
	
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
	
	if popup_type == PopUpTypes.ClickDrag:
		return create_click_drag(block_data)
		
	if popup_type == PopUpTypes.SpotLight:
		return create_spotlight(block_data)
	return false

func create_time_location_pop_up(block_data:Dictionary)->bool:
	var pop_up:TimeLocationPopUpControl = load("res://Scenes/Dialog/PopUps/TimeLocationPopup/time_local_popup.tscn").instantiate()
	var location = block_data.get("Location", "The Location")
	var time = block_data.get("Time", "X years ago")
	pop_up.set_location_and_time(location, time)
	self.add_child(pop_up)
	var wait_to_finish = block_data.get("WaitToFinish", true)
	if wait_to_finish:
		parent_dialog_controller._block_states["LocationTimePopUp"] = DialogController.BlockStates.Playing
		pop_up.outro_finished.connect(parent_dialog_controller._on_popup_finished.bind("LocationTimePopUp"))
	return wait_to_finish
	

## Returns true if block should be waitied on
func create_highlight(block_data:Dictionary)->bool:
	var popup_key = block_data.get("Create", null)
	var screen_size = parent_dialog_controller.get_viewport_rect().size
	var popup_pos = null
	var popup_size = null
	
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
			popup_size = target_element.get_global_rect().size
			
			var hack_scale = block_data.get("HackScale", [1,1])
			popup_size.x = popup_size.x * hack_scale[0]
			popup_size.y = popup_size.y * hack_scale[1]
			
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

func create_spotlight(block_data):
	var pop_up_key = block_data.get("Create", null)
	if !pop_up_key:
		printerr("DialogController: No 'PopUpKey' provided on SpeechBubble block.")
		return false
	var actor_id = block_data.get("ActorId")
	if !actor_id:
		return false
	var spotlight:SpotLightControl = load("res://Scenes/Dialog/PopUps/SpotLight/spot_light_popup.tscn").instantiate()
	spotlight.set_actor(actor_id)
	self.add_child(spotlight)
	_popups[pop_up_key] = spotlight
	return false

func create_click_drag(block_data):
	var pop_up_key = block_data.get("Create", null)
	if !pop_up_key:
		printerr("DialogController: No 'PopUpKey' provided on SpeechBubble block.")
		return false
	var new_popup:ClickDragPopUpControl = load("res://Scenes/Dialog/PopUps/ClickDragPopUp/click_drag_pop_up_control.tscn").instantiate()
	parent_dialog_controller.add_child(new_popup)
	new_popup.set_dialog_block(parent_dialog_controller, block_data)
	parent_dialog_controller._block_states[pop_up_key] = DialogController.BlockStates.Playing
	new_popup.finished.connect(parent_dialog_controller._on_popup_finished.bind(pop_up_key))
	return true
	
