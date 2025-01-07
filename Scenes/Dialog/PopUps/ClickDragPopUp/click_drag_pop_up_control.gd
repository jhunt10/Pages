class_name ClickDragPopUpControl
extends Control

enum States {Clicking, Dragging, Done}

signal finished

@export var click_control:Control
@export var click_outline_patch:NinePatchRect
@export var drag_control:Control
@export var drag_outline_patch:NinePatchRect

@export var click_button:Button

@export var state:States:
	set(val):
		print("SetState: " + str(state))
		state = val
		if state == States.Clicking:
			click_outline_patch.show()
			drag_outline_patch.hide()
		elif state == States.Dragging:
			click_outline_patch.hide()
			drag_outline_patch.show()
		elif state == States.Done:
			click_outline_patch.hide()
			drag_outline_patch.hide()

var target_click_element:Control
var mimic_drag_data:Dictionary = {}

func _ready() -> void:
	click_button.button_down.connect(_on_click)
	click_button.button_up.connect(_on_drag_finished)
	state = States.Clicking
		
func set_dialog_block(parent_dialog_controller, block_data):
	
	var click_path = block_data.get("ClickTargetPath", null)
	var click_padding = block_data.get("ClickTargetPadding", [0,0,0,0])
	if !click_path:
		printerr("No ClickTargetPath provided.")
		return
	var click_target_rect = get_target_rect(parent_dialog_controller, click_path, click_padding, true)
	click_control.position = click_target_rect.position
	click_control.size = click_target_rect.size
	
	var drag_path = block_data.get("DragTargetPath", null)
	var drag_padding = block_data.get("ClickTargetPadding", [0,0,0,0])
	if !drag_path:
		printerr("No DragTargetPath provided.")
		return
	var drag_target_rect = get_target_rect(parent_dialog_controller, drag_path, drag_padding)
	drag_control.position = drag_target_rect.position
	drag_control.size = drag_target_rect.size
	
	if block_data.has("MimicItemDragData"):
		mimic_drag_data = block_data['MimicItemDragData'].duplicate()

func _on_click():
	print("Button Down")
	state = States.Dragging
	if mimic_drag_data.size() > 0:
		var offset = target_click_element.get_local_mouse_position()
		if CharacterMenuControl.Instance:
			var item_id = ""
			var index = 0
			if mimic_drag_data.has("Index"):
				if mimic_drag_data['Context'] == "Equipment":
					index = mimic_drag_data['Index']
					item_id = CharacterMenuControl.Instance._actor.equipment.get_item_id_in_slot(index)
			elif mimic_drag_data.has("ItemKey"):
				if mimic_drag_data['Context'] == "Inventory":
					var item = PlayerInventory.get_item_by_key(mimic_drag_data['ItemKey'])
					if item:
						item_id = item.Id
						index = -1
						
			if item_id != "":
				CharacterMenuControl.Instance.on_item_button_down(mimic_drag_data['Context'], item_id, index, offset)

func _on_drag_finished():
	print("Button Up")
	var mouse_pos = drag_outline_patch.get_local_mouse_position()
	print("MouseUp: " + str(mouse_pos))
	if mouse_pos.x > 0 and mouse_pos.x < drag_outline_patch.size.x and mouse_pos.y > 0 and mouse_pos.y < drag_outline_patch.size.y:
		state = States.Done
		if mimic_drag_data.size() > 0:
			if CharacterMenuControl.Instance:
				var item_id = ""
				var index = 0
				var target_context = mimic_drag_data.get("TargetContext", "Inventory")
				if mimic_drag_data.has("Index"):
					if mimic_drag_data['Context'] == "Equipment":
						index = mimic_drag_data['Index']
						item_id = CharacterMenuControl.Instance._actor.equipment.get_item_id_in_slot(mimic_drag_data['Index'])
				elif mimic_drag_data.has("ItemKey"):
					if mimic_drag_data['Context'] == "Inventory":
						var item = PlayerInventory.get_item_by_key(mimic_drag_data['ItemKey'])
						if item:
							item_id = item.Id
							index = -1
							CharacterMenuControl.Instance._mouse_over_index_data = mimic_drag_data['EquipPageSlot']
							
				CharacterMenuControl.Instance._selected_context = mimic_drag_data['Context']
				CharacterMenuControl.Instance._mouse_over_context = target_context
				
				CharacterMenuControl.Instance.on_item_button_up(mimic_drag_data['Context'], item_id, index)
		finished.emit()
		self.queue_free()
	else:
		state = States.Clicking

func get_target_rect(parent_dialog_controller, target_element_path:String, padding:Array, save_target:bool=false)->Rect2:
	var target_element = null
	if parent_dialog_controller.scene_root:
		target_element = parent_dialog_controller.scene_root.get_node(target_element_path)
	if !target_element:
		printerr("PopUpDialogBlock: No Target Element found.")
		return Rect2(0,0,0,0)
	var rect = Rect2(0,0,0,0)
	if target_element is Control:
		rect.position = target_element.get_screen_position()
		rect.size = target_element.get_global_rect().size
		rect.size.x += padding[0]
		rect.size.y += padding[2]
		rect.size.x += padding[1] - padding[0]
		rect.size.y += padding[3] - padding[2]
		if save_target:
			target_click_element = target_element
	return rect
