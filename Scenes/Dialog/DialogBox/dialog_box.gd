class_name DialogBox
extends Control

const DEFAULT_LETTER_DELAY:float = 0.01
const DEFAULT_QUESTION_OPTION_DELAY:float = 0.3
const LINE_WRAP_PADDING:int = 0

enum EntryTypes {Clear, Delay, Speaker, Text, Flag, Question, WaitToRead, BackTrack, IconImage, Hide, TextColor}
enum STATES {Ready, Printing, Done, Question}

signal finished_printing
signal question_answered(choice:String)

@export var state:STATES = STATES.Ready
@export var speaker_container:VBoxContainer
@export var speaker_portrait:TextureRect
@export var speaker_label:Label
@export var scroll_bar:CustScrollBar
@export var entry_contaier:VBoxContainer
@export var scroll_contaier:ScrollContainer

@export var read_timer_label:Label
@export var hidden_text_edit:TextEdit
@export var premade_text_label:RichTextLabel
@export var premade_compound_label:RichTextLabel
@export var premade_question_option:DialogQuestionOption
@export var unknown_speaker_port:Texture2D

var _entry_que:Array = []
var _current_text_entry:RichTextLabel
var _question_options:Dictionary ={}
var _delay_timer:float = 0
var _reader_timer:float = 0
	#set(val):
		#print("_reader_timer: %s" % [val])
		#_reader_timer = val

# When true, will check for word wrap on next TextEntry process 
var _word_is_broken:bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	premade_text_label.hide()
	premade_compound_label.hide()
	premade_question_option.hide()
	_clear_speaker()

var _starting_read:bool = false

func _process(delta: float) -> void:
	#if delta > DEFAULT_LETTER_DELAY:
		#print("DialogBlock: Delta less than Delay: %s | %s" % [DEFAULT_LETTER_DELAY, delta])
	#read_timer_label.text =  "%s | %2.3f" % [state, _reader_timer * 100]
	if state == STATES.Printing:
		
		if _delay_timer <= delta and _entry_que.size() > 0:
			var current_entry = _entry_que[0]
			var remaining_delta = min(0.03, delta - _delay_timer)
			if _handle_entry(current_entry, delta, remaining_delta):
				_entry_que.remove_at(0)
				_starting_read = false
		else:
			#print("Delay: %s | Delta: %s" % [_delay_timer, delta])
			_delay_timer = _delay_timer - delta
		
		if _delay_timer <= 0 and _entry_que.size() <= 0:
			state = STATES.Done
			finished_printing.emit()
			return

func add_entry(entry_data:Dictionary):
	_entry_que.append(entry_data)
	if state == STATES.Ready or state == STATES.Done:
		state = STATES.Printing

func add_entries(entry_arr:Array):
	_entry_que.append_array(entry_arr)
	if state == STATES.Ready or state == STATES.Done:
		state = STATES.Printing

## Returns true if entry is finished
func _handle_entry(entry_data:Dictionary, raw_delta, remaining_delta)->bool:
	var conditions = entry_data.get("ConditionFlags", {})
	for flag_name in conditions.keys():
		var flag_val = conditions[flag_name]
		if StoryState.get_story_flag(flag_name) != flag_val:
			return true
	
	var entry_type_str = entry_data.get("EntryType", '')
	var entry_type = EntryTypes.get(entry_type_str)
	if entry_type == null:
		printerr("Unknown DialogBox EntryType: '%s'." % [entry_type_str])
	
	#----------------------------------
	#          Clear
	# Options:
	# 	 "ClearSpeaker": bool (true) | Clear Speaker Namd and Portrait
	# 	 "ClearText": bool (true) | Clear displayed text
	#----------------------------------
	if entry_type == EntryTypes.Clear:
		if entry_data.get("ClearSpeaker", true):
			_clear_speaker()
		_reader_timer = 0.0
		if entry_data.get("ClearText", true):
			for child in entry_contaier.get_children():
				if child == premade_text_label: continue
				if child == premade_question_option: continue
				if child == hidden_text_edit: continue
				if child == premade_compound_label: continue
				child.queue_free()
		hidden_text_edit.clear()
		_word_is_broken = true
		scroll_bar.calc_bar_size()
		scroll_bar.hide()
		_delay_timer = -1
		_current_text_entry = null
		return true
		
	#----------------------------------
	#          Hide
	# Options:
	# 	 "ClearSpeaker": bool (true) | Clear Speaker Namd and Portrait
	# 	 "ClearText": bool (true) | Clear displayed text
	#----------------------------------
	if entry_type == EntryTypes.Hide:
		self.hide()
		return true
	
	
	#----------------------------------
	#          Flag
	# 	Gets the current value of a story flag and replaces self with Text entry with flag as Text value.
	#----------------------------------
	if entry_type == EntryTypes.Flag:
		var flag_name = entry_data.get("FlagName")
		var val = StoryState.get_story_flag(flag_name)
		if val:
			entry_data['Text'] = str(val)
			entry_data['EntryType'] = 'Text'
			entry_type = EntryTypes.Text
	
	#----------------------------------
	#          Delay
	# Options:
	# 	 "Delay": Float (-1) | Second delay
	#----------------------------------
	if entry_type == EntryTypes.Delay:
		_delay_timer = entry_data.get("Delay", -1)
		return true
	
	#----------------------------------
	#          Speaker
	# Options:
	# 	"SpeakerName": String (null) | Displayed name of speaker (keep <= 4 chars)
	# 	"SpeakerPort": String (null) | File path of portrait texture
	# 	If both are null, speaker box is cleared
	#----------------------------------
	elif entry_type == EntryTypes.Speaker:
		var speaker_name = entry_data.get("SpeakerName", null)
		if speaker_name:
			speaker_label.text = speaker_name
		var speaker_port = entry_data.get("SpeakerPort", null)
		if speaker_port:
			if speaker_port == "Unknown":
				speaker_portrait.texture = unknown_speaker_port
			else:
				speaker_portrait.texture = SpriteCache.get_sprite(speaker_port)
			speaker_portrait.show()
		if speaker_name or speaker_port:
			speaker_container.show()
		else:
			_clear_speaker()
		_delay_timer = -1
		return true
	
	#----------------------------------
	#          Color
	# Options:
	# 	"Color": Array<float> | Color of text
	#----------------------------------
	elif entry_type == EntryTypes.TextColor:
		var color_arr = entry_data.get("Color", [0,0,0,0])
		var color = Color(color_arr[0],color_arr[1],color_arr[2],color_arr[3])
		_current_text_entry.push_color(color)
		return true
		
	
	#----------------------------------
	#          TEXT
	# Options:
	# 	"NewLine": Bool (false) | Start a new RTLabel for the text.
	# 	"Text": String ("") | Text to be printed
	# 	"LetterDelay": Float (CONST) | Override for default letter delay
	#----------------------------------
	elif entry_type == EntryTypes.Text:
		var text = entry_data.get("Text", null)
		var word_break = false
		if not text: return true
		if not entry_data.has("RemainingText"):
			entry_data['RemainingText'] = text
			_word_is_broken = true
		
		# Create new entry if none exist or requested
		if not _current_text_entry or entry_data.get("NewLine", false) or entry_data.get("CompoundLine", false):
			var is_compound = entry_data.get("CompoundLine", false)
			_create_new_text_entry(is_compound)
			if not is_compound:
				hidden_text_edit.clear()
				_word_is_broken = true
			entry_data['NewLine'] = false
			entry_data['CompoundLine'] = false
		
		var remaining_text:String = entry_data['RemainingText']
		# Finished with block
		if remaining_text.length() == 0:
			return true
		
		var letter_delay = entry_data.get("LetterDelay", DEFAULT_LETTER_DELAY)
		while remaining_delta >= 0 and remaining_text.length() > 0:
			var new_char = remaining_text.substr(0,1)
			remaining_text = remaining_text.trim_prefix(new_char)
			
			# Chack for command
			if new_char == "@":
				var next_at = remaining_text.find('@')
				if next_at > 0:
					var command = remaining_text.substr(0,next_at)
					#printerr("\nSpecal Command: %s" % [command])
					_handle_special_command(command)
					remaining_text = remaining_text.trim_prefix(command + '@')
					new_char = remaining_text.substr(0,1)
					remaining_text = remaining_text.trim_prefix(new_char)
			
			# Check line wrap
			if new_char == ' ':
				_word_is_broken = true
				if not hidden_text_edit.text.ends_with(' '):
					hidden_text_edit.text += " "
			elif _word_is_broken:
				_word_is_broken = false
				var tokens = remaining_text.replace(' ', ' #@#').split("#@#")
				if tokens.size() > 0:
					var next_word:String = new_char + tokens[0]
					# Remove command text
					if next_word.contains('@'):
						var sub_tokens = next_word.split('@')
						next_word = sub_tokens[0]
						if sub_tokens.size() > 2:
							next_word += sub_tokens[2]
					hidden_text_edit.text += next_word
					var line_length = hidden_text_edit.get_line_width(0)
					#print("Next Word: '%s' | Line Length: %s" % [next_word, line_length])
					if line_length > entry_contaier.size.x - LINE_WRAP_PADDING:
						print("Size Limit: %s" % [(entry_contaier.size.x )])
						_current_text_entry.append_text('\n')
						#print("\n Clip Line: '%s' \n" % [hidden_text_edit.text.trim_suffix(next_word)])
						hidden_text_edit.clear()
						hidden_text_edit.text = next_word
			entry_data['RemainingText'] = remaining_text
			_current_text_entry.append_text(new_char)
			_update_scrolling()
			remaining_delta -= letter_delay
		if remaining_text.length() > 0:
			_delay_timer = entry_data.get("LetterDelay", DEFAULT_LETTER_DELAY) - remaining_delta
			return false
	
	#----------------------------------
	#          Back Track
	# Options:
	# 	"Text": String ("") | Text to be deleted from current text entry
	# 	"LetterDelay": Float (CONST) | Override for default letter delay
	#----------------------------------
	elif entry_type == EntryTypes.BackTrack:
		var text = entry_data.get("Text", null)
		if not text: return true
		if not _current_text_entry: return true
		if not entry_data.has("RemainingText"):
			entry_data['RemainingText'] = text
			hidden_text_edit.text = hidden_text_edit.text.trim_suffix(text)
			
		var remaining_text:String = entry_data['RemainingText']
		if remaining_text.length() == 0:
			return true
		var remove_char = remaining_text.substr(remaining_text.length()-1,1)
		remaining_text = remaining_text.trim_suffix(remove_char)
		entry_data['RemainingText'] = remaining_text
		var cur_text = _current_text_entry.get_parsed_text()
		cur_text = cur_text.trim_suffix(remove_char)
		_current_text_entry.text = ''
		_current_text_entry.append_text(cur_text)
		_update_scrolling()
		if remaining_text.length() > 0:
			_delay_timer = entry_data.get("LetterDelay", DEFAULT_LETTER_DELAY) - remaining_delta
		return false
	
	#----------------------------------
	#          Question
	# Options:
	# 	"Choices": Dictionary ({}) | Answer options mapped by display text
	# 	Example: { "Yes": "Question1_Yes" }
	#----------------------------------
	elif entry_type == EntryTypes.Question:
		_current_text_entry = null
		var question_options = entry_data.get("Choices", {})
		for choice_text in question_options.keys():
			var choice_key = question_options[choice_text]
			if _question_options.keys().has(choice_key):
				continue
			var new_button:DialogQuestionOption = premade_question_option.duplicate()
			new_button.set_option_text(choice_text)
			entry_contaier.add_child(new_button)
			new_button.show()
			_question_options[choice_key] = new_button
			new_button.button.pressed.connect(_on_question_optioon_pressed.bind(choice_key))
			_delay_timer = DEFAULT_QUESTION_OPTION_DELAY
			return false
		state = STATES.Question
		return true
	
	#----------------------------------
	#          Wait To Read
	# 	Stay in Printing state until _read_timer has finished
	# 	Should only be used at end of block. Othwersize it can not wait for next button.
	#----------------------------------
	elif entry_type == EntryTypes.WaitToRead:
		if _current_text_entry and not _starting_read:
			#printerr("Staring Read Timer: %s | %s" % [_reader_timer, _current_text_entry.get_parsed_text()])
			#print("Read------------------------------------------------------------------------------------------")
			_starting_read = true
			_reader_timer = _estimate_read_time(_current_text_entry.get_parsed_text())
		_reader_timer -= raw_delta
		#print("Read Timer: %s" % [_reader_timer])
		return _reader_timer <= 0
	
	
	elif entry_type == EntryTypes.IconImage:
		var image_path = entry_data.get("Image", '')
		var image = SpriteCache.get_sprite(image_path)
		_current_text_entry.add_image(image)
	return true

func _create_new_text_entry(compound:bool):
	var new_text:RichTextLabel = null
	if compound:
		var line_container = null
		if _current_text_entry:
			var parent = _current_text_entry.get_parent()
			if parent is HBoxContainer:
				line_container = parent
		if not line_container:
			line_container = HBoxContainer.new() 
			line_container.add_theme_constant_override("seperation", 0)
			entry_contaier.add_child(line_container)
		new_text = premade_compound_label.duplicate()
		new_text.text = ''
		line_container.add_child(new_text)
	else:
		new_text = premade_text_label.duplicate()
		new_text.text = ''
		entry_contaier.add_child(new_text)
		
	new_text.show()
	_current_text_entry = new_text

func _estimate_read_time(text:String)->float:
	# TODO: Account for special logic characters
	if text.replace(".", "").replace(" ", "") == "":
		return 0
	var word_cound:float = text.replace(".", "").split(" ").size()
	var avg_wpm:float = 260
	var seconds:float = (word_cound / avg_wpm) * 60.0
	#printerr("Estimated Read: '%s' | %s" % [text,seconds])
	return  0.5#max(1, seconds * 1.0)

func _clear_speaker():
	speaker_portrait.texture = unknown_speaker_port
	speaker_label.text = ""
	speaker_container.hide()

func _handle_special_command(command:String):
	#printerr("DialogCommand: %s" % [command])
	if command.begins_with("Color:"):
		var tokens = command.split(":")
		if tokens[1] == "Red":
			_current_text_entry.push_bold()
			_current_text_entry.push_color(Color.RED)
		if tokens[1] == "Blue":
			_current_text_entry.push_bold()
			_current_text_entry.push_color(Color.DARK_BLUE)
		if tokens[1] == "Green":
			_current_text_entry.push_bold()
			_current_text_entry.push_color(Color.GREEN)
	else:
		_current_text_entry.pop_all()
	return false

func _update_scrolling():
	if entry_contaier.size.y > scroll_contaier.size.y:
		scroll_bar.show()
		scroll_contaier.scroll_vertical = entry_contaier.size.y - scroll_contaier.size.y
		scroll_bar.calc_bar_size()
		scroll_bar.set_scroll_bar_percent(100)
	else:
		scroll_bar.hide()
		scroll_contaier.scroll_vertical = 0

func _on_question_optioon_pressed(choice_key):
	print("Selected Choice: " + choice_key)
	for option_key in _question_options.keys():
		var option:DialogQuestionOption = _question_options[option_key]
		if option_key == choice_key:
			question_answered.emit(choice_key)
			option.set_selected(true)
		else:
			option.queue_free()
	_question_options.clear()
	state = STATES.Printing

func _build_test():
	_entry_que = [
		{
			"EntryType": "Clear"
		},
		{
			"EntryType": "Speaker",
			"SpeakerName": "Test",
			"SpeakerPort": "res://defs/Actors/NPCs/MnFg/Sprites/Portraits/MysFig_Smile.png"
		},
		{
			"EntryType": "Text",
			"Text": "Hello, Cun..."
		},
		{
			"EntryType": "BackTrack",
			"Text": "Cun...",
			"LetterDelay": 0.1
		},
		{
			"EntryType": "Text",
			"Text": "Friend!"
		},
		{
			"EntryType": "Text",
			"NewLine": true,
			"Text": "It's nice to @SomeCommand@meet you.",
		},
		{
			"EntryType": "WaitToRead",
		},
		{
			"EntryType": "Clear",
			"ClearSpeaker":false
		},
		#{
			#"EntryType":"Text",
			#"Text":"A rooky Soldier who was separated from their company before their first battle. Unable to find their allies and in fear of being branded a deserter,  they find themselves wondering aimlessly when they come upon a Mysterious Figure"
		#},
		{
			"EntryType": "Text",
			"Text": "Would you like to see a fish?",
		},
		{
			"EntryType": "Question",
			"Choices": {"Yes": "Test_YES", "No": "Test_NO"}
		},{
			"EntryType": "Text",
			"Text": "Your answer didn't really matter.",
		},
		{
			"EntryType": "WaitToRead"
		},
		{
			"EntryType": "Clear",
			"ClearSpeaker":true
		},
		{
			"EntryType": "Speaker",
			"SpeakerName": "FMrc",
			"SpeakerPort":"res://defs/Actors/NPCs/FishMerch/FishMerch_Sleeping.png"
		},
		{
			"EntryType": "Text",
			"Text": "Now here's a fish!"
		},
		
	]
	
