class_name QuestionDialogBlock
extends BaseDialogBlock

@export var question_text_box:RichTextLabel
@export var options_container:VBoxContainer 
var premade_option:DialogQuestionOption:
	get: return $DialogQuestionOption

var line_index:int
var letter_index:int

func _ready() -> void:
	premade_option.visible = false
	pass

func set_block_data(parent_control, data):
	question_text_box.clear()
	question_text_box.text = ''
	super(parent_control, data)

func do_thing():
	var question_text = _block_data.get("QuestionText", null)
	if !question_text:
		finished.emit()
		return
	
	# Print next letter
	if question_text.length() > letter_index:
		question_text_box.append_text(question_text.substr(letter_index,1))
		letter_index += 1
		_delay_timer = LETTER_DELAY
		return
		
	var options = _block_data.get("Options", [])
	var option_index = options_container.get_children().size() 
	if  options.size() > option_index:
		var new_option:DialogQuestionOption = premade_option.duplicate()
		new_option.set_option_text(options[option_index])
		options_container.add_child(new_option)
		new_option.show()
		new_option.button.pressed.connect(on_option_selected.bind(option_index))
		_parent_dialog_control.scroll_to_bottom()
		_delay_timer = LINE_DELAY
		return
	## Finished all lines
	#else:
		#_finished = true
		#self.finished.emit()

func on_option_selected(index:int):
	if self._finished:
		return
	var option:DialogQuestionOption = options_container.get_children()[index]
	option.set_selected(true)
	self._finished = true
	finished.emit()
