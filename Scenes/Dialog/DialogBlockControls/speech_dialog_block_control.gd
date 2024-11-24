class_name SpeechDialogBlockControl
extends Container

@export var speaker_label:RichTextLabel
@export var text_box:RichTextLabel

var dialog_block:SpeechDialogBlock
var line_index:int
var letter_index:int

var _delay_timer:float
var _paused:bool
var is_finished:bool

func _process(delta: float) -> void:
	if !dialog_block or dialog_block._finished:
		return
	if is_finished or _paused:
		return
	if _delay_timer > 0:
		_delay_timer -= delta
		if _delay_timer <= 0:
			print_text()

func start():
	self._delay_timer = 0.001

func resume():
	if _paused:
		_paused = false
		if !is_finished and self._delay_timer <= 0:
			self._delay_timer = 0.001

func print_text():
	if is_finished:
		return
	var lines:Array = dialog_block.get_block_data().get("Lines", [])
	# Print next line
	if lines.size() > line_index:
		dialog_block._parent_dialog_control.scroll_to_bottom()
		var current_line:String = lines[line_index]
		# Line Starting
		if letter_index == 0:
			# Special Command Line
			if current_line.begins_with("@"):
				# Set min delay
				_delay_timer = 0.0001
				if current_line == "@WaitForNextButton":
					dialog_block.wait_for_next_button()
					_paused = true
				if current_line.begins_with("@Delay:"):
					var tokens = current_line.split(":")
					var delay = float(tokens[1])
					_delay_timer = delay
				line_index += 1
				return
		# Print next letter
		if current_line.length() > letter_index:
			text_box.append_text(current_line.substr(letter_index,1))
			letter_index += 1
			_delay_timer = dialog_block.LETTER_DELAY
			return
		# Line Finished
		else:
			line_index += 1
			letter_index = 0
			_delay_timer = dialog_block.LINE_DELAY
			return
	# Finished all lines
	else:
		is_finished = true

func set_dailog_block(block:SpeechDialogBlock):
	self.dialog_block = block
	text_box.clear()
	text_box.text = ''
	if dialog_block.get_block_data().keys().has("Speaker"):
		speaker_label.text = dialog_block.get_block_data().get("Speaker", "") + ": "
	else:
		speaker_label.hide()

## Returns true if the block was completed while skipping
func try_skip()->bool:
	var lines:Array = dialog_block.get_block_data().get("Lines", [])
	if lines.size() > line_index:
		var current_line = lines[line_index]
		# Print rest of current line
		if letter_index > 0 and current_line.length() > letter_index:
			text_box.append_text(current_line.substr(letter_index))
			line_index += 1
		letter_index = 0
		# Print remaining lines
		for index in range(line_index, lines.size()):
			line_index = index
			current_line = lines[line_index]
			if current_line.begins_with("@"):
				if current_line == "@WaitForNextButton":
					line_index += 1
					dialog_block.wait_for_next_button()
					_paused = true
					return false
			else:
				text_box.append_text(lines[index])
	is_finished = true
	return true
