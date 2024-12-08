class_name DialogControl
extends Control

const LOGGING = false

const LETTER_DELAY:float = 0.03
@export var scene_root:Node
@export var dialog_box_holder:Control
@export var popup_holder:Control
@export var dialog_box:Control
@export var next_button:Button
@export var scroll_container:ScrollContainer
@export var blocks_container:VBoxContainer

var _start_position

var dialog_script_data:Array
var block_tags:Array
var meta_data:Dictionary = {}
var popups:Dictionary
var current_block:BaseDialogBlock
var block_index:int
var delay_timer:float = 0

var waiting_for_button:bool = false
var _scroll_to_bottom:bool = true
var _delayed_scroll:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	next_button.pressed.connect(on_next_button_pressed)
	_start_position = dialog_box.position
	#load_dialog_script("res://Scenes/Dialog/_ExampleDialogScript.json")#
	#load_dialog_script("res://data/DialogScripts/TutorialDialog.json")
	if dialog_script_data.size() > 0:
		start_dialog()
	else:
		printerr("No Dialog Script loaded on _ready")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _scroll_to_bottom and current_block:
		scroll_container.ensure_control_visible(blocks_container)
		_scroll_to_bottom = false
	if waiting_for_button:
		return
	if current_block and not current_block.is_finished:
		current_block.update(delta)

func _input(event: InputEvent) -> void:
	if !self.visible or !dialog_box_holder.visible:
		return
	if event is InputEventMouseButton:
		var mouse_event =  (event as InputEventMouseButton)
		if mouse_event.button_index == 1 and mouse_event.pressed:
			if next_button.visible:
				if current_block and current_block.read_any_touch_as_next():
					on_next_button_pressed()
				elif not current_block:
					on_next_button_pressed()
			else:
				if current_block and not current_block.is_finished:
					if LOGGING: print("Skipping")
					current_block.skip()
					scroll_to_bottom()

func start_dialog():
	next_button.hide()
	start_block()

func start_block():
	if LOGGING: print("Starting Block %s" % [block_index])
	if dialog_script_data.size() > block_index:
		var new_block_data:Dictionary = dialog_script_data[block_index]
		if new_block_data.keys().has("@LABEL@"):
			printerr("LabelBlock: " + new_block_data['@LABEL@'])
			block_index += 1
			start_block()
			return
		var new_block = await create_new_block(new_block_data)
		if !new_block:
			printerr("DialogControl: create_new_block failed on index %s" % [block_index])
			current_block = null
			block_finished()
			return
		current_block = new_block
		current_block.finished.connect(block_finished)
		if current_block._block_data.keys().has("FreezeCamera"):
			CombatRootControl.Instance.camera.freeze = current_block._block_data.get("FreezeCamera")
		current_block.start()

func create_new_block(block_data):
	var block_script_path = block_data.get("BlockScript")
	if !block_script_path:
		printerr("DialogControl: No BlockScript found on script block #%s" % [block_index])
		return null
		
	var script = load(block_script_path)
	if !script:
		printerr("DialogControl: Failed to find script: %s" % [block_script_path])
		return null
	var new_block = script.new(self, block_data)
	return new_block

func block_finished(from_next_button:bool=false):
	if LOGGING: print("Block Finished")
	var next_index = block_index + 1
	if current_block:
		if current_block._block_data.get("WaitForButton", true) and not from_next_button:
			show_next_button()
			return
		var next_tag = current_block.get_next_block_tag()
		if next_tag:
			print("Jumping to block %s" % [next_tag])
			var index = block_tags.find(next_tag)
			if index < 0:
				printerr("Failed to find next block with tag: %s" % [next_tag])
			else:
				next_index = index
		current_block.delete()
		current_block.finished.disconnect(block_finished)
	if dialog_script_data.size() > next_index:
		block_index = next_index
		start_block()
	else:
		self.hide()
		CombatRootControl.Instance.camera.freeze = false

func show_next_button():
	if LOGGING: print("Show Next Button")
	next_button.show()
	waiting_for_button = true

func add_block_container(new_block):
	blocks_container.add_child(new_block)
	new_block.show()
	var scroll_bar_size = scroll_container.get_v_scroll_bar().size.x
	new_block.custom_minimum_size = Vector2(blocks_container.size.x-scroll_bar_size, scroll_container.size.y)
	await get_tree().process_frame
	scroll_container.ensure_control_visible(new_block)

func scroll_to_bottom():
	#scroll_container.ensure_control_visible(current_block)
	_scroll_to_bottom = true

func load_dialog_script(file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	var text:String = file.get_as_text()
	dialog_script_data = JSON.parse_string(text)
	block_tags = []
	for block_data in dialog_script_data:
		if block_data.keys().has("BlockTag"):
			block_tags.append(block_data['BlockTag'])
		else:
			block_tags.append(null)

func on_next_button_pressed():
	if LOGGING: print("Next Button Pressed")
	waiting_for_button = false
	next_button.hide()
	if current_block and current_block.is_finished:
		block_finished(true)

func add_popup(key, pop_up, pos=null):
	if popups.keys().has(key):
		printerr("DialogControl: Popup with key: '%s' already exists." % [key])
		return
	popups[key] = pop_up
	popup_holder.add_child(pop_up)
	if LOGGING: print("---Added Pop Up")
	if pos:
		pop_up.position = pos

func remove_popup(key):
	if popups.keys().has(key):
		popups[key].queue_free()
		popups.erase(key)
