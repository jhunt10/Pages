class_name DialogBox
extends Control

const DEFAULT_LETTER_DELAY:float = 0.03
const DEFAULT_QUESTION_OPTION_DELAY:float = 0.3

enum EntryTypes {Clear, Delay, Speaker, Text, Question, WaitToRead, BackTrack, IconImage}
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
@export var premade_text_label:RichTextLabel
@export var premade_question_option:DialogQuestionOption

var _entry_que:Array = []
var _current_text_entry:RichTextLabel
var _question_options:Dictionary ={}
var _delay_timer:float = 0
var _reader_timer:float = 0
	#set(val):
		#print("_reader_timer: %s" % [val])
		#_reader_timer = val

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	premade_text_label.hide()
	premade_question_option.hide()
	_clear_speaker()

var _starting_read:bool = false

func _process(delta: float) -> void:
	#if delta > DEFAULT_LETTER_DELAY:
		#print("DialogBlock: Delta less than Delay: %s | %s" % [DEFAULT_LETTER_DELAY, delta])
	#read_timer_label.text =  "%s | %2.3f" % [state, _reader_timer * 100]
	if state == STATES.Printing:
		if _entry_que.size() <= 0:
			state = STATES.Done
			finished_printing.emit()
			return
		_delay_timer = _delay_timer - delta
		if _delay_timer <= 0:
			var current_entry = _entry_que[0]
			if _handle_entry(current_entry, delta):
				_entry_que.remove_at(0)
				_starting_read = false

func add_entry(entry_data:Dictionary):
	_entry_que.append(entry_data)
	if state == STATES.Ready or state == STATES.Done:
		state = STATES.Printing

func add_entries(entry_arr:Array):
	_entry_que.append_array(entry_arr)
	if state == STATES.Ready or state == STATES.Done:
		state = STATES.Printing

## Returns true if entry is finished
func _handle_entry(entry_data:Dictionary, delta)->bool:
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
		for child in entry_contaier.get_children():
			if child == premade_text_label: continue
			if child == premade_question_option: continue
			child.queue_free()
		scroll_bar.calc_bar_size()
		scroll_bar.hide()
		_delay_timer = -1
		return true
	
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
			speaker_portrait.texture = SpriteCache.get_sprite(speaker_port)
			speaker_portrait.show()
		if speaker_name or speaker_port:
			speaker_container.show()
		else:
			_clear_speaker()
		_delay_timer = -1
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
		if not text: return true
		if not _current_text_entry or entry_data.get("NewLine", false):
			_create_new_text_entry()
			entry_data['NewLine'] = false
		if not entry_data.has("RemainingText"):
			entry_data['RemainingText'] = text
			#entry_data['EstimateReadTime'] = _estimate_read_time(text)
		var remaining_text:String = entry_data['RemainingText']
		if remaining_text.length() == 0:
			#_reader_timer += entry_data['EstimateReadTime']
			return true
		#_reader_timer -= delta
		var new_char = remaining_text.substr(0,1)
		remaining_text = remaining_text.trim_prefix(new_char)
		entry_data['RemainingText'] = remaining_text
		if new_char == "@":
			var command_end_index = remaining_text.find("@")
			if command_end_index < 0:
				printerr("Unterminated Command in text: %s" % [text])
				_delay_timer = -1
				return true
			var command_str = remaining_text.substr(0, command_end_index)
			remaining_text = remaining_text.trim_prefix(command_str + "@")
			entry_data['RemainingText'] = remaining_text
			return _handle_special_command(command_str)
		else:
			_current_text_entry.append_text(new_char)
			_update_scrolling()
			if remaining_text.length() > 0:
				_delay_timer = entry_data.get("LetterDelay", DEFAULT_LETTER_DELAY)
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
		var remaining_text:String = entry_data['RemainingText']
		if remaining_text.length() == 0:
			return true
		var remove_char = remaining_text.substr(remaining_text.length()-1,1)
		remaining_text = remaining_text.trim_suffix(remove_char)
		entry_data['RemainingText'] = remaining_text
		var cur_text = _current_text_entry.get_parsed_text()
		cur_text = cur_text.trim_suffix(remove_char)
		_current_text_entry.text = cur_text
		_update_scrolling()
		if remaining_text.length() > 0:
			_delay_timer = entry_data.get("LetterDelay", DEFAULT_LETTER_DELAY)
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
		if not _starting_read:
			#printerr("Staring Read Timer: %s | %s" % [_reader_timer, _current_text_entry.get_parsed_text()])
			#print("Read------------------------------------------------------------------------------------------")
			_starting_read = true
			_reader_timer = _estimate_read_time(_current_text_entry.get_parsed_text())
		_reader_timer -= delta
		#print("Read Timer: %s" % [_reader_timer])
		return _reader_timer <= 0
	
	elif entry_type == EntryTypes.IconImage:
		var image_path = entry_data.get("Image", '')
		var image = SpriteCache.get_sprite(image_path)
		_current_text_entry.add_image(image)
	return true

func _create_new_text_entry():
	var new_text:RichTextLabel = premade_text_label.duplicate()
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
	speaker_portrait.texture = null
	speaker_label.text = ""
	speaker_container.hide()

func _handle_special_command(command:String):
	printerr("DialogCommand: %s" % [command])
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
	
