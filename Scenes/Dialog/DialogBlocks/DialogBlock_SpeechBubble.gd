class_name SpeechBubbleDialogBlock
extends BaseDialogBlock

func _init(parent, data):
	data['WaitForButton'] = false
	super(parent, data)

func do_thing():
	if _block_data.keys().has("Delete"):
		destory_popup()
	if _block_data.keys().has("Create"):
		create_popup()
	if not _block_data.get("WaitToFinish", false):
		self._finished = true
		self.finished.emit()

func create_popup():
	var bubble_key = _block_data.get("Create", null)
	var display_text = _block_data.get("Text", null)
	var target_actor_id = _block_data.get("TargetActorId", null)
	var actor_node = CombatRootControl.get_actor_node(target_actor_id)
	
	var new_bubble:SpeachBubbleVfxNode = load("res://Scenes/VFXs/SpeachBubble/speach_bubble_vfx_node.tscn").instantiate()
	actor_node.vfx_holder.add_child(new_bubble)
	new_bubble.display_text = display_text
	new_bubble.showing = true
	new_bubble.position = Vector2(8,-21)
	_parent_dialog_control.popups[bubble_key] = new_bubble
	if _block_data.get("WaitToFinish", false):
		new_bubble
	

func destory_popup():
	var bubble_key = _block_data.get("Delete", null)
	if bubble_key and _parent_dialog_control.popups.has(bubble_key):
		var bubble:SpeachBubbleVfxNode = _parent_dialog_control.popups[bubble_key]
		bubble.showing = false
		_parent_dialog_control.popups.erase(bubble_key)

func pop_up_showing():
	destory_popup()
	self._finished = true
	self.finished.emit()
