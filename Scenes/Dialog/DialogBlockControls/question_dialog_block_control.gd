class_name QuestionDialogBlockControl
extends Container

signal option_selected(index:int)

@export var question_text_box:RichTextLabel
@export var options_container:VBoxContainer 
@export var speaker_label:RichTextLabel
@export var portrait_rect:TextureRect
var premade_option:DialogQuestionOption:
	get: return $HBoxContainer/VBoxContainer2/DialogQuestionOption

var dialog_block:QuestionDialogBlock
var line_index:int
var letter_index:int
var _delay_timer:float

var _done_printing:bool
var _selected_index:int = -1

func _ready() -> void:
	premade_option.visible = false
	pass

func start():
	self._delay_timer = 0.001

func set_dailog_block(block:QuestionDialogBlock):
	self.dialog_block = block
	question_text_box.clear()
	question_text_box.text = ''
	var block_data = block.get_block_data()
	if block_data.keys().has("Speaker") and block_data.get("Speaker", null):
		speaker_label.text = dialog_block.get_block_data().get("Speaker", "") + ": "
	else:
		speaker_label.hide()
	if block_data.keys().has("PortraitTexture") and block_data.get("PortraitTexture", null):
		var port = SpriteCache.get_sprite(block_data.get("PortraitTexture"))
		if port:
			portrait_rect.texture = port
	else:
		portrait_rect.hide()

func _process(delta: float) -> void:
	if !dialog_block or dialog_block.is_finished:
		return
	if _done_printing:
		return
	if _delay_timer > 0:
		_delay_timer -= delta
		if _delay_timer <= 0:
			print_text()

func print_text():
	var question_text = dialog_block._block_data.get("QuestionText", null)
	if !question_text:
		return
	
	# Print next letter
	if question_text.length() > letter_index:
		question_text_box.append_text(question_text.substr(letter_index,1))
		letter_index += 1
		_delay_timer = dialog_block.LETTER_DELAY
		return
		
	var options = dialog_block._block_data.get("Options", [])
	var option_index = options_container.get_children().size() 
	if  options.size() > option_index:
		create_option(options[option_index], option_index)
	else:
		_done_printing = true
	## Finished all lines

func create_option(option_text, option_index):
	var new_option:DialogQuestionOption = premade_option.duplicate()
	new_option.set_option_text(option_text)
	options_container.add_child(new_option)
	new_option.show()
	new_option.button.pressed.connect(on_option_selected.bind(option_index))
	if dialog_block:
		dialog_block._parent_dialog_control.scroll_to_bottom()
	_delay_timer = dialog_block.LINE_DELAY
	if not MainRootNode.is_mobile:
		new_option.button.mouse_entered.connect(mouse_enter_option.bind(option_index))
		new_option.button.mouse_exited.connect(mouse_exit_option.bind(option_index))

func print_all():
	var question_text = dialog_block._block_data.get("QuestionText", null)
	question_text_box.text = question_text
	var options = dialog_block._block_data.get("Options", [])
	var option_index = options_container.get_children().size() 
	while options.size() > option_index:
		create_option(options[option_index], option_index)
		option_index += 1
	_done_printing = true
	

func mouse_enter_option(index:int):
	if _selected_index < 0:
		var option:DialogQuestionOption = options_container.get_child(index)
		option.set_selected(true)
	
func mouse_exit_option(index:int):
	if _selected_index < 0:
		var option:DialogQuestionOption = options_container.get_child(index)
		option.set_selected(false)

func on_option_selected(index:int):
	for child in options_container.get_children():
		child.set_selected(false)
	var option:DialogQuestionOption = options_container.get_children()[index]
	option.set_selected(true)
	_selected_index = index
	option_selected.emit(index)
