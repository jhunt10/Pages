class_name DialogControl
extends Control

const LETTER_DELAY:float = 0.03
@export var scene_root:Node
@export var premade_blocks:Control
@export var popup_holder:Control
@export var dialog_box:Control
@export var next_button:Button
@export var scroll_container:ScrollContainer
@export var blocks_container:VBoxContainer

@export var seperator:Label
@export var premade_speech_block:SpeechDialogBlock
@export var premade_question_block:QuestionDialogBlock
@export var premade_position_block:PositionBoxDialogBlock
@export var premade_popup_block:PopUpBoxDialogBlock

var _start_position

var dialog_script_data:Array
var popups:Dictionary
var current_block:BaseDialogBlock
var block_index:int
var delay_timer:float = 0
var waiting_for_button:bool = false
var _scroll_to_bottom:bool = true
var _delayed_scroll:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	premade_speech_block.hide()
	seperator.hide()
	premade_question_block.hide()
	next_button.pressed.connect(on_next_button_pressed)
	_start_position = dialog_box.position
	load_dialog_script("res://data/DialogScripts/TutorialDialog.json")
	start_dialog()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _scroll_to_bottom and current_block:
		scroll_container.ensure_control_visible(current_block)
		_scroll_to_bottom = false
	#if waiting_for_button:
		#return
	#if delay_timer > 0:
		#delay_timer -= delta
		#if delay_timer <= 0:
			#do_thing()

func _input(event: InputEvent) -> void:
	if !self.visible:
		return
	if event is InputEventMouseButton:
		var mouse_event =  (event as InputEventMouseButton)
		if mouse_event.button_index == 1 and mouse_event.pressed:
			if next_button.visible:
				on_next_button_pressed()
			else:
				if current_block:
					current_block.skip()
					print("Skipping")
					scroll_to_bottom()

func start_dialog():
	next_button.hide()
	start_block()

func start_block():
	print("Starting Block %s" % [block_index])
	if dialog_script_data.size() > block_index:
		#if block_index > 0:
			#var new_seperator = seperator.duplicate()
			#new_seperator.show()
			#blocks_container.add_child(new_seperator)
		var new_block_data = dialog_script_data[block_index]
		var new_block = await create_new_block(new_block_data)
		if current_block:
			current_block.archive()
		current_block = new_block
		current_block.start()

func create_new_block(block_data):
	var block_type = block_data.get("BlockType")
	var premade = premade_blocks.get_node(block_type)
	if !premade:
		printerr("Failed to find premade DialogBlock: %s" % [block_type])
		return
		
	var new_block = premade.duplicate()
	if !new_block:
		printerr("Unknown DialogBlock Type: %s" %[block_type])
		return
		
	blocks_container.add_child(new_block)
	new_block.show()
	new_block.custom_minimum_size = Vector2(blocks_container.size.x, scroll_container.size.y-8)
	await get_tree().process_frame
	scroll_container.ensure_control_visible(new_block)
	new_block.finished.connect(block_finished)
	new_block.set_block_data(self, block_data)
	return new_block
		 

func block_finished():
	if current_block._block_data.get("WaitForButton", true):
		show_next_button()
		return
	if dialog_script_data.size() > block_index + 1:
		block_index += 1
		start_block()
	else:
		self.hide()

func show_next_button():
	print("Show Next Button")
	next_button.show()
	waiting_for_button = true

func scroll_to_bottom():
	#scroll_container.ensure_control_visible(current_block)
	_scroll_to_bottom = true

func load_dialog_script(file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	var text:String = file.get_as_text()
	dialog_script_data = JSON.parse_string(text)

func on_next_button_pressed():
	print("Next Button Pressed")
	waiting_for_button = false
	next_button.hide()
	if current_block and current_block._finished:
		block_index += 1
		start_block()

func add_popup(key, pop_up, pos=null):
	if popups.keys().has(key):
		printerr("Popup with key: '%s' already exists." % [key])
		return
	popups[key] = pop_up
	popup_holder.add_child(pop_up)
	print("---Added Pop Up")
	if pos:
		pop_up.position = pos

func remove_popup(key):
	if popups.keys().has(key):
		popups[key].queue_free()
		popups.erase(key)
