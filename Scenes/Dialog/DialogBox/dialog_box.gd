class_name DialogBox
extends Control

const DEFAULT_LETTER_DELAY:float = 0.03
const DEFAULT_LINE_DELAY:float = 0.1

enum EntryTypes {Clear, Speaker, Text, Question, WaitToRead, BackTrack}
enum STATES {Ready, Printing, Done}

signal finished_printing

@export var state:STATES
@export var speaker_container:VBoxContainer
@export var speaker_portrait:TextureRect
@export var speaker_label:Label
@export var scroll_bar:CustScrollBar
@export var entry_contaier:VBoxContainer

@export var read_timer_label:Label
@export var premade_text_label:RichTextLabel

var _entry_que:Array = []
var _current_text_entry:RichTextLabel
var _delay_timer:float = 0
var _reader_timer:float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	premade_text_label.hide()
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
			"EntryType": "Clear"
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
	state = STATES.Printing
	pass # Replace with function body.


func _process(delta: float) -> void:
	if delta > DEFAULT_LETTER_DELAY:
		printerr("DialogBlock: Delta less than Delay: %s | %s" % [DEFAULT_LETTER_DELAY, delta])
	read_timer_label.text =  "%s | %2.3f" % [state, _reader_timer * 100]
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

func add_entry(entry_data:Dictionary):
	pass

## Returns true if entry is finished
func _handle_entry(entry_data:Dictionary, delta)->bool:
	var entry_type_str = entry_data.get("EntryType", '')
	var entry_type = EntryTypes.get(entry_type_str)
	if entry_type == null:
		printerr("Unknown DialogBox EntryType: '%s'." % [entry_type_str])
	
	#----------------------------------
	#          Clear
	#----------------------------------
	if entry_type == EntryTypes.Clear:
		speaker_container.hide()
		speaker_portrait.texture = null
		speaker_label.text = ''
		for child in entry_contaier.get_children():
			if child == premade_text_label: continue
			child.queue_free()
		scroll_bar.calc_bar_size()
		scroll_bar.hide()
		_delay_timer = -1
		return true
	
	#----------------------------------
	#          Speaker
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
			speaker_container.hide()
		_delay_timer = -1
		return true
	
	#----------------------------------
	#          TEXT
	#----------------------------------
	elif entry_type == EntryTypes.Text:
		var text = entry_data.get("Text", null)
		if not text: return true
		if not _current_text_entry or entry_data.get("NewLine", false):
			_create_new_text_entry()
			entry_data['NewLine'] = false
		if not entry_data.has("RemainingText"):
			entry_data['RemainingText'] = text
			entry_data['EstimateReadTime'] = _estimate_read_time(text)
		var remaining_text:String = entry_data['RemainingText']
		if remaining_text.length() == 0:
			_reader_timer += entry_data['EstimateReadTime']
			return true
		_reader_timer -= delta
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
			if remaining_text.length() > 0:
				_delay_timer = entry_data.get("LetterDelay", DEFAULT_LETTER_DELAY)
			return false
	
	#----------------------------------
	#          Back Track
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
		print("Cur Text: %s | Rmv: %s" %[cur_text, remove_char])
		cur_text = cur_text.trim_suffix(remove_char)
		print("After Remove: %s | Rmv: %s" %[cur_text, remove_char])
		_current_text_entry.text = cur_text
		if remaining_text.length() > 0:
			_delay_timer = entry_data.get("LetterDelay", DEFAULT_LETTER_DELAY)
		return false
	#----------------------------------
	#          Wait
	#----------------------------------
	elif entry_type == EntryTypes.WaitToRead:
		_reader_timer -= delta
		#print("Read Timer: %s" % [_reader_timer])
		return _reader_timer <= 0
	
	return true

func _create_new_text_entry():
	var new_text:RichTextLabel = premade_text_label.duplicate()
	new_text.text = ''
	entry_contaier.add_child(new_text)
	new_text.show()
	_current_text_entry = new_text

func _estimate_read_time(text:String)->float:
	# TODO: Account for special logic characters
	var word_cound:float = text.split(" ").size()
	var avg_wpm:float = 230
	var seconds:float = (word_cound / avg_wpm) * 60.0
	return seconds * 1.0

func _handle_special_command(command:String):
	printerr("DialogCommand: %s" % [command])
	return false
