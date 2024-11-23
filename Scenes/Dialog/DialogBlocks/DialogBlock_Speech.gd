class_name SpeechDialogBlock
extends BaseDialogBlock

@export var speaker_label:RichTextLabel
@export var text_box:RichTextLabel

var line_index:int
var letter_index:int

func _process(delta: float) -> void:
	if self._finished:
		return
	
	if !_parent_dialog_control or !_block_data:
		return
		
	if _parent_dialog_control.waiting_for_button:
		return
	
	if _delay_timer > 0:
		_delay_timer -= delta
		if _delay_timer <= 0:
			do_thing()

func do_thing():
	var lines:Array = _block_data.get("Lines", [])
	# Print next line
	if lines.size() > line_index:
		_parent_dialog_control.scroll_to_bottom()
		var current_line:String = lines[line_index]
		# Line Starting
		if letter_index == 0:
			# Special Command Line
			if current_line.begins_with("@"):
				# Set min delay
				_delay_timer = 0.0001
				if current_line == "@WaitButton":
					_parent_dialog_control.show_next_button()
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
			_delay_timer = LETTER_DELAY
			return
		# Line Finished
		else:
			line_index += 1
			letter_index = 0
			_delay_timer = LINE_DELAY
			return
	# Finished all lines
	else:
		_finished = true
		self.finished.emit()

func set_block_data(parent_control, data):
	text_box.clear()
	text_box.text = ''
	if data.keys().has("Speaker"):
		speaker_label.text = data.get("Speaker", "") + ": "
	else:
		speaker_label.hide()
	super(parent_control, data)

func on_skip():
	var lines:Array = _block_data.get("Lines", [])
	if lines.size() > line_index:
		var current_line = lines[line_index]
		if letter_index > 0 and current_line.length() > letter_index:
			text_box.append_text(current_line.substr(letter_index))
			line_index += 1
		letter_index = 0
		for index in range(line_index, lines.size()):
			line_index = index
			if lines[index].begins_with("@"):
				if current_line == "@WaitButton":
					_parent_dialog_control.show_next_button()
					line_index += 1
					return
			else:
				text_box.append_text(lines[index])
	_finished = true
	self.finished.emit()
	
		
