class_name DialogController
extends Control

const LOGGING = false

enum STATES {Ready, Playing, WaitingForBlocks, WaitingForNextButton, WaitingForCondition, Finished}

enum BlockTypes {
	WaitForAsync,
	Delay, 
	SetFlag, 
	SpeechBox, 
	MoveActor, 
	Blackout, 
	PanCamera, 
	PopUp,
	ClearQue, 
	SpawnActor,
	TextInput,
	NextStory,
	CustomBlock,
	AnimateNode,
	StartCombat,
	DecrementStoryIndex
}

@export var scene_root:Node
@export var next_button:DialogControlButton
@export var skip_button:DialogControlButton
@export var auto_button:AutoDialogControlButton
@export var top_speech_box:DialogBox
@export var bot_speech_box:DialogBox
@export var blackout_control:BlackOutControl
@export var dialog_popup_controller:DialogPopUpController
@export var input_blocker:Control


var _condition_flags:Dictionary:
	get:
		return StoryState._story_flags
var _condition_watcher:BaseDialogConditionWatcher
var _custom_blocks:Dictionary = {}
var _animation_players:Dictionary = {}

## Dialog scripts are divided into "parts" made up of "blocks"
var _dialog_part_datas:Dictionary
var _cur_part_key:String
var _state:STATES = STATES.Ready:
	set(val):
		if _state != val:
			#print("DialogController: Setting State '%s'." % [STATES.keys()[val]])
			_state = val
			if next_button:
				if _state == STATES.WaitingForNextButton:
					printerr("Part TIme: %s" % [_part_start_timer])
					_part_start_timer = 0
					if auto_button.is_on:
						_delay_timer = max(0.5, _delay_timer + 0.5)
						_state = STATES.Playing
					else:
						next_button.show()
				else:
					next_button.hide()

enum BlockStates {Playing, WaitingForNextButton, Finished}
## Mapping of block_id to is_finished
var _block_states:Dictionary = {}

## Data for current part is duplicated from _dialog_part_datas to allow for altering but still replaying
var _current_part_data:Dictionary
var _last_block_data:Dictionary

var _delay_timer:float = -1
var _part_start_timer:float

# Blocks are "fire and forget", they are given thier data, kicked off, and moved on
# (_cur_block_data is saved for postarity)
# If a block has any logic that holds up the Part, they flag themselves with "WaitToFinish"
# 	and some key for them is added to _block_states. When they finish, they report back and 
# 	update thier value in _block_states. 


# Skipping: Goes to next part. 
#			Current part is entirly abandoned and next part started
#			Skipping will be haulted if a question is answered. Question should be at start of blocks.
# ForceFinish: Goes to final state of current part. 
#			Final state will need to be determined by cycleing over all blocks.
# AutoPlay: Will automaticly move to next part when all blocks of current part finish.

func _ready() -> void:
	next_button.hide()
	skip_button.button.pressed.connect(_on_skip)
	next_button.button.pressed.connect(_on_next_button_pressed)
	top_speech_box.finished_printing.connect(_on_speech_box_finished.bind(true))
	bot_speech_box.finished_printing.connect(_on_speech_box_finished.bind(false))
	blackout_control.fade_done.connect(_on_blackout_finished)
	bot_speech_box.question_answered.connect(_on_question_answered)
	top_speech_box.hide()
	bot_speech_box.hide()

func _process(delta: float) -> void:
	_part_start_timer += delta
	if _state == STATES.WaitingForCondition:
		if not _condition_watcher:
			printerr("DialogController: WaitingForCondition with no condition watcher.")
			_state = STATES.Playing
		else:
			_condition_watcher.update(delta)
			if _condition_watcher.is_finished():
				_state = STATES.Playing
			
	if _state == STATES.WaitingForBlocks:
		if _are_blocks_playing():
			return
		if _last_block_data and _last_block_data.get("WaitForNextButton", false):
			_state = STATES.WaitingForNextButton
			return
		else:
			_state = STATES.Playing
	if _state == STATES.Playing:
		if _delay_timer > 0:
			_delay_timer -= delta
			#print("Delay TImer: %s" % [_delay_timer])
			return
		if _are_blocks_waiting_for_next_button():
			next_button.show()
			_state = STATES.WaitingForBlocks
			return
		var part_finished = true
		# Cycle through blocks, removing them as they are handled
		while _current_part_data['Blocks'].size() > 0:
			_last_block_data = _current_part_data['Blocks'][0]
			_current_part_data['Blocks'].remove_at(0)
			# Each block only has _handle_block called once on it
			var waiting_on_block = _handle_block(_last_block_data)
			if waiting_on_block:
				_state = STATES.WaitingForBlocks 
				return
			if _delay_timer > 0:
				return
		
		# All blocks are finished and we are still in Playing state
		if _current_part_data['Blocks'].size() == 0 and _state == STATES.Playing:
			
			# Part says to wait for next button
			if _current_part_data.get("WaitForNextButton", false):
				_current_part_data['WaitForNextButton'] = false
				_state = STATES.WaitingForNextButton
				return
			
			var next_part_key = _get_next_part_key()
			if next_part_key:
				_start_part(next_part_key)
			else:
				printerr("No Next Part Key Found")
				_finish_dialog()

## Returns true if any blocks are currently playing
func _are_blocks_playing():
	var is_playing = false
	for key in _block_states.keys():
		if _block_states[key] == BlockStates.Playing:
			is_playing = true
		#else:
			#_block_states.erase(key)
	return is_playing

## Returns true if any block is waiting for the "Next" button
func _are_blocks_waiting_for_next_button():
	var is_playing = false
	for key in _block_states.keys():
		if _block_states[key] == BlockStates.WaitingForNextButton:
			is_playing = true
		#else:
			#_block_states.erase(key)
	return is_playing

## Returns key for next part of script checking in order:
## Condition Watcher's get_next_part_key
## Result of '_NextPartLogic' if any cases are valid
## '_NextPartKey' if present
func _get_next_part_key():
	if _condition_watcher:
		var condition_key = _condition_watcher.get_next_part_key()
		if condition_key != '':
			return condition_key
			
	var next_part_logic = _current_part_data.get("_NextPartLogic", null)
	if next_part_logic:
		var flag_name = next_part_logic.get("FlagName", null)
		if _condition_flags.has(flag_name):
			var flag_val = _condition_flags.get(flag_name)
			var cases  = next_part_logic.get("Cases", {})
			if cases.has(flag_val):
				return cases[flag_val]
		var flag_val:String = str(StoryState.get_story_flag(flag_name))
		var cases  = next_part_logic.get("Cases", {})
		if cases.has(flag_val):
			return cases[flag_val]
		elif cases.has('@DEFAULT@'):
			return cases['@DEFAULT@']
	return _current_part_data.get("_NextPartKey", null)

func _start_part(part_key:String):
	if LOGGING: print("Starting  part: " + part_key)
	_part_start_timer = 0
	_cur_part_key = part_key
	_condition_watcher = null
	if not _dialog_part_datas.has(part_key):
		printerr("DialogControl: No script part found with key '%s'." % [part_key])
		_finish_dialog()
		return
	_current_part_data = _dialog_part_datas[part_key].duplicate(true)
	if not _current_part_data.keys().has('Blocks'):
		_current_part_data['Blocks'] = []
	
	if CombatRootControl.Instance:
		CombatRootControl.Instance.camera.locked_for_cut_scene = _current_part_data.get("LockCamera", true)
	
	if _current_part_data.get("DecrementStoryIndex", false):
		StoryState._story_stage_index -= 1
	
	if _current_part_data.has("EnsurePoses"):
		var force_poses = _current_part_data['EnsurePoses']
		force_positions(force_poses)
	
	if _current_part_data.get("Inital_BlackOutState", null):
		blackout_control.set_state_string(_current_part_data['Inital_BlackOutState'])
	
	if _current_part_data.get("AllowInputThrough", false):
		input_blocker.hide()
	else:
		input_blocker.show()
	if _current_part_data.get("HideDialogUI", false):
		self.hide()
	else:
		self.show()
	
	if _current_part_data.has("ConditionWatcherScript"):
		var script_path = _current_part_data['ConditionWatcherScript']
		var script = load(script_path)
		if not script:
			printerr("DialogController._start_part: No script found with name '%s'." % [script_path])
			return null
		_condition_watcher = script.new()
		_condition_watcher.set_data(self, _current_part_data)
		_state = STATES.WaitingForCondition
	else:
		_state = STATES.Playing

func _finish_dialog():
		_state = STATES.Finished
		if CombatRootControl.Instance:
			CombatRootControl.Instance.camera.locked_for_cut_scene = false
		self.queue_free()

func _on_skip():
	# Can't skip watchers
	if _current_part_data.has("ConditionWatcherScript"):
		return
	if _current_part_data.has("OnSkip"):
		var on_skip_data = _current_part_data.get("OnSkip")
		if not on_skip_data.get("CanSkip", true):
			return
		for block in on_skip_data.get("Blocks", {}):
			_handle_block(block)
	if CombatRootControl.Instance:
		for actor_node:ActorNode in CombatRootControl.Instance.MapController.actor_nodes.values():
			actor_node.force_finish_movement()
	var next_part_key = _get_next_part_key()
	if LOGGING: print("Skipping to part: %s" % [next_part_key])
	top_speech_box.clear_entries()
	top_speech_box.hide()
	bot_speech_box.clear_entries()
	bot_speech_box.hide()
	dialog_popup_controller.clear_popups()
	_block_states.clear()
	if next_part_key:
		_start_part(next_part_key)
	else:
		_finish_dialog()
	

## Returns true if block should be waitied on
func _handle_block(block_data:Dictionary)->bool:
	var block_type_str = block_data.get("BlockType", '')
	if block_type_str == "MainMenu":
		MainRootNode.Instance.go_to_main_menu()
		return true
	if LOGGING: print("Handeling Block: " + block_type_str)
	var block_type = BlockTypes.get(block_type_str)
	if block_type == null:
		printerr("Unknown DialogBox BlockType: '%s'." % [block_type_str])
		return false
	
	#----------------------------------
	#          Custom Block
	# Options:
	# 	"ScriptPath" String: Path to Custom Block script
	#----------------------------------
	if block_type == BlockTypes.CustomBlock:
		var script_path = block_data.get("ScriptPath", null)
		if not script_path: return false
		var script = load(script_path)
		if not script: return false
		var new_block:BaseCustomDialogBlock = script.new()
		if new_block.handle_block(self, block_data):
			var new_id = str(ResourceUID.create_id())
			new_block.finished.connect(_on_custom_block_finished.bind(new_id))
			_custom_blocks[new_id] = new_block
			return true
		return false
	
	
	#----------------------------------
	#          Wait For Async
	# Description:
	# 	Wait for Async blocks which started but didn't stop flow
	#----------------------------------
	if block_type == BlockTypes.WaitForAsync:
		return true
	
	#----------------------------------
	#          Delay
	# Options:
	# 	"Time" Float: Time to delay for
	#----------------------------------
	if block_type == BlockTypes.Delay:
		var time = block_data.get("Time", -1)
		_delay_timer = time
		return false
	
	#----------------------------------
	#          Set Flag
	# Options:
	# 	"FlagName" String
	#----------------------------------
	if block_type == BlockTypes.SetFlag:
		var flag_name = block_data.get("FlagName", null)
		if !flag_name:
			return false
		var val = block_data.get("Value", null)
		StoryState.set_story_flag(flag_name, val)
		return false
	
	#----------------------------------
	#          Speech
	# Options:
	# 	"WaitToFinish": Bool(false): Add "Speech" to list of block states
	# 	"TopBox": Bool(false): Apply this block to top dialog box
	# 	"Hide": Bool(false): Hide dialog box
	# 	"Entries": Array[Dic] | Entry data for speach block
	#----------------------------------
	if block_type == BlockTypes.SpeechBox:
		var top_box = block_data.get("TopBox", false)
		var hide_box = block_data.get("Hide", false)
		if top_box:
			top_speech_box.add_entries(block_data.get("Entries", []))
			if hide_box: top_speech_box.hide()
			elif not top_speech_box.visible: top_speech_box.show()
		else:
			bot_speech_box.add_entries(block_data.get("Entries", []))
			if hide_box: bot_speech_box.hide()
			elif not bot_speech_box.visible: bot_speech_box.show()
		if block_data.get("WaitToFinish", false):
			if top_box:
				_block_states['TopSpeech'] = BlockStates.Playing
			else:
				_block_states['BotSpeech'] = BlockStates.Playing
			return true
	
	#----------------------------------
	#          Pan Camera
	# Options:
	# 	"WaitToFinish": Bool(false): Add "PanCamera" to list of block states
	# 	"TargetType": [MapPos | Actor | PathMarker] | Entry data for speach block
	#
	# 	Actor Options:
	# 	"ActorId": Id of actor
	#
	# 	MapPos Options:
	# 	"MapPos": Int Array
	#
	# 	PathMarker Options:
	# 	"PathMarkerName": Name of path marker to go to
	#----------------------------------
	if block_type == BlockTypes.PanCamera:
		var target_type:String = block_data.get("TargetType")
		var target_pos:MapPos = null
		if target_type == "MapPos":
			var map_pos_arr:Array = block_data.get("MapPos")
			target_pos = MapPos.new(map_pos_arr[0], map_pos_arr[1], 0, 0)
		elif target_type == "Actor":
			var actor_id = block_data.get("ActorId")
			actor_id = translate_actor_id(actor_id)
			var actor_node = CombatRootControl.get_actor_node(actor_id)
			target_pos = actor_node.cur_map_pos
		elif target_type == "PathMarker":
			var marker_name = block_data.get("PathMarkerName")
			var marker = CombatRootControl.Instance.MapController.get_path_marker(marker_name)
			if !marker:
				printerr("DialogControl.PanCamera: No PathMarker found with name '%s'." % [marker_name])
				return false
			target_pos = marker.get_map_pos()
		if not target_pos:
			return false
		CombatRootControl.Instance.camera.start_auto_pan_to_map_pos(target_pos)
		if block_data.get("WaitToFinish", false):
			if not CombatRootControl.Instance.camera.panning_finished.is_connected(_on_camera_pan_finish):
				CombatRootControl.Instance.camera.panning_finished.connect(_on_camera_pan_finish)
			_block_states['PanCamera'] = BlockStates.Playing
			return true
	
	
	#----------------------------------
	#          Black Out
	# Options:
	# 	"WaitToFinish": Bool(false): Add "BlackOut" to list of block states
	# 	"BlackOutState": [ Black | FadeIn | Clear | FadeOut ]
	# 	 "FadeValue" Float(1): Fade limit for Blackout alpha 
	#----------------------------------
	if block_type == BlockTypes.Blackout:
		var blackout_state = block_data.get("BlackOutState", null)
		var fade_val = block_data.get("FadeValue", 1)
		if blackout_state == null:
			printerr("DialogController: No 'BlackOutState' provided on BlackOut block.")
			blackout_state = "Clear"
		blackout_control.fade_limit = fade_val
		blackout_control.set_state_string(blackout_state)
		if block_data.get("WaitToFinish", false):
			if blackout_state == "FadeIn" or blackout_state == "FadeOut":
				_block_states['BlackOut'] = BlockStates.Playing
				return true
			else:
				printerr("DialogController: Non-waitable BlackOutState: '%s'." % [blackout_state])
	
	#----------------------------------
	#          Move Actor
	# Options:
	# 	"WaitToFinish": Bool(false): Add "[ActorId]:Move" to list of block states
	# 	 "TargetActorId": String: Id of actor to start moving
	# 	 "PathMarkerName": String : Name of PathMarker for actor to follow
	# 	 "FollowActor": Bool(false): Should camera follow actor
	# 	 "SpeedScale": Float(1.0): Speed multiplier of movement speed (default assumes 1 turn per tile)
	#----------------------------------
	if block_type == BlockTypes.MoveActor:
		if _do_move_actor(block_data):
			var target_actor_id = block_data.get("TargetActorId")
			target_actor_id = translate_actor_id(target_actor_id)
			var target_actor = ActorLibrary.get_actor(target_actor_id)
			if block_data.get("FollowActor", false):
				CombatRootControl.Instance.camera.lock_to_actor(target_actor)
			if block_data.get("WaitToFinish", false) or block_data.get("AsyncWaitToFinish", false):
				var move_key = target_actor_id+":Move"
				_block_states[move_key] = BlockStates.Playing
				var actor_node = CombatRootControl.get_actor_node(target_actor_id)
				if not actor_node.reached_motion_destination.is_connected(_on_actor_move_finished):
					actor_node.reached_motion_destination.connect(_on_actor_move_finished.bind(target_actor_id))
				return block_data.get("WaitToFinish", false)
	
	#----------------------------------
	#         Pop Up
	# Options:
	# 	 "WaitToFinish": Bool(false): Add "[PopUp_Id]" to list of block states
	# 	 "PopUpType": String (See PopupController for options)
	# 	 "Create": String : Key for popup to be created
	# 	 "Delete": String : Key for popup to be deleted
	#----------------------------------
	if block_type == BlockTypes.PopUp:
		var wait_on_pop_up = dialog_popup_controller.handle_pop_up(block_data)
		if wait_on_pop_up:
			return true

	#----------------------------------
	#         Animate Node
	# Options:
	# 	 "WaitToFinish": Bool(false): Add "[PopUp_Id]" to list of block states
	# 	 "TargetElement": Path of node with Animation player as first child
	# 	 "AnimationName": Name of animation to play
	#----------------------------------
	if block_type == BlockTypes.AnimateNode:
		var target_element_path = block_data.get("TargetElement", null)
		if not target_element_path:
			return false
		var target_element = self.scene_root.get_node(target_element_path)
		if not target_element:
			printerr("DialogControler AnimateNode: Failed to find node: %s" % [target_element_path])
			return false
		var animation_player = target_element.get_child(0)
		if not (animation_player is AnimationPlayer):
			printerr("DialogControler AnimateNode: First child of node is not AnimationPlayer: %s" % [target_element_path])
			return false
		var animation_name = block_data.get("AnimationName", "")
		var wait_to_finish = block_data.get("WaitToFinish", false)
		if animation_name == "HIDE":
			target_element.hide()
			return false
		if wait_to_finish:
			var key = target_element_path + ":" + animation_name 
			(animation_player as AnimationPlayer).animation_finished.connect(_on_animation_finished.bind(key))
			_block_states[key] = BlockStates.Playing
			_animation_players[key] = animation_player
		(animation_player as AnimationPlayer).play(animation_name)
		return wait_to_finish
		
	#----------------------------------
	#         Clear Que
	# clears player que
	#----------------------------------
	if block_type == BlockTypes.ClearQue:
		var player_actor = StoryState.get_player_actor()
		player_actor.Que.clear_que()
		return false
	
	#----------------------------------
	#         Spawn Actor
	# Options:
	# 	 "SpawnNodeName": Name of Spawn Node to be triggered.
	# 	 "SpawnNodeList": Array of Name of Spawn Node to be triggered.
	#----------------------------------
	if block_type == BlockTypes.SpawnActor:
		if LOGGING: print("DialogBlock: Spawing Actor %s" %[Time.get_unix_time_from_system()])
		var spawn_node_list = block_data.get("SpawnNodeList", [])
		var single_name = block_data.get("SpawnNodeName") 
		if single_name != null:
			spawn_node_list.append(single_name)
		for spawn_node_name in spawn_node_list:
			var spawn_node = CombatRootControl.Instance.MapController.get_spawn_node(spawn_node_name)
			if !spawn_node:
				printerr("DialogController.SpawnActor: Failed to find Spawn Node: %s" %[spawn_node_name])
				continue
			var actor_key = spawn_node.spawn_actor_key
			var actor_id = spawn_node.spawn_actor_id
			var actor_pos = spawn_node.get_map_pos()
			var new_actor = ActorLibrary.get_or_create_actor(actor_key, actor_id)
			CombatRootControl.Instance.add_actor(new_actor, actor_pos)
	
	
	
	#----------------------------------
	#          Text Input
	# Options:
	# 	"TitleMessage" String
	# 	"PlaceHolder" String
	#----------------------------------
	if block_type == BlockTypes.TextInput:
		var title_text = block_data.get("TitleMessage")
		if not title_text: return false
		var place_holder = block_data.get("PlaceHolder", "")
		var new_input:DialogTextInput = load("res://Scenes/Dialog/DialogTextInput/dialog_text_input_control.tscn").instantiate()
		new_input.set_texts(title_text, place_holder)
		self.add_child(new_input)
		new_input.input_confirmed.connect(_on_text_input)
		_block_states["TextInput"] = BlockStates.Playing
		return true
	
	#----------------------------------
	#          Next Story
	# Description: Progress to next story stage.
	#----------------------------------
	if block_type == BlockTypes.NextStory:
		_state = STATES.Finished
		StoryState.load_next_story_scene()
		_block_states["NextScene"] = BlockStates.Playing
		if CombatRootControl.Instance:
			CombatRootControl.Instance.camera.locked_for_cut_scene = false
		return true
	
	#----------------------------------
	#          Start COmbat
	# Options:
	#----------------------------------
	if block_type == BlockTypes.StartCombat:
		if CombatRootControl.Instance and not CombatRootControl.Instance.combat_started:
			if not CombatRootControl.Instance.start_combat_screen.screen_blacked_out.is_connected(_on_combat_start_blackout):
				CombatRootControl.Instance.start_combat_screen.screen_blacked_out.connect(_on_combat_start_blackout)
			CombatRootControl.Instance.start_combat_animation()
			_block_states["StartCombat"] = BlockStates.Playing
			return true
		return false
	
	# Unknown Block
	return false

func load_dialog_script(file_path, wait_for_load_screen:bool=true):
	var file = FileAccess.open(file_path, FileAccess.READ)
	var text:String = file.get_as_text()
	var data = JSON.parse_string(text)
	load_dialog_data(data)
	if wait_for_load_screen:
		_state = STATES.Ready
		LoadManager._load_screen.loading_screen_fully_gone.connect(_on_load_screen_finshed)
	
func load_dialog_data(data:Dictionary):
	_condition_watcher = null
	_dialog_part_datas = data
	if not _dialog_part_datas.keys().has("_MetaData_"):
		printerr("No _MetaData_ found in dialog script.")
		_dialog_part_datas.clear()
		self.queue_free()
		return
	var meta_data = _dialog_part_datas["_MetaData_"]
	var start_part_key = meta_data.get("StartPartKey", null)
	if !start_part_key:
		printerr("No 'StartPartKey' found in _MetaData_ of dialog script.")
		_dialog_part_datas.clear()
		self.queue_free()
		return
	_cur_part_key = start_part_key
	if meta_data.has("Inital_BlackOutState"):
		blackout_control.set_state_string(meta_data['Inital_BlackOutState'])
		
	_start_part(_cur_part_key)

func _on_load_screen_finshed():
	self._state = STATES.Playing
	LoadManager._load_screen.loading_screen_fully_gone.disconnect(_on_load_screen_finshed)

func _on_combat_start_blackout():
	_block_states["StartCombat"] = BlockStates.Finished
	pass

func _on_animation_finished(animation_name:String, key:String):
	if LOGGING: print("Animation Finished: %s" % [animation_name])
	var animation_player = _animation_players[key]
	(animation_player as AnimationPlayer).animation_finished.disconnect(_on_animation_finished)
	_animation_players.erase(key)
	_block_states[key] = BlockStates.Finished
	

func _on_speech_box_finished(is_top:bool):
	if LOGGING: print("Speech Box Finished")
	if is_top and _block_states.has("TopSpeech"):
		_block_states['TopSpeech'] = BlockStates.Finished
	if not is_top and _block_states.has("BotSpeech"):
		_block_states['BotSpeech'] = BlockStates.Finished

func _on_blackout_finished():
	if LOGGING: print("BlackOut Finished")
	if _block_states.has("BlackOut"):
		_block_states["BlackOut"] = BlockStates.Finished

func _on_actor_move_finished(actor_id):
	var move_key = actor_id+":Move"
	if _block_states.has(move_key):
		_block_states[move_key] = BlockStates.Finished
	var camera = CombatRootControl.Instance.camera
	var actor_node = CombatRootControl.get_actor_node(actor_id)
	if not CombatRootControl.Instance.QueController.is_executing:
		if (camera.following_actor_node and  camera.following_actor_node.Actor.Id == actor_id):
			camera.clear_following_actor()
			camera.snap_to_map_pos(actor_node.cur_map_pos)
	if actor_node.reached_motion_destination.is_connected(_on_actor_move_finished):
		actor_node.reached_motion_destination.disconnect(_on_actor_move_finished)

func _on_camera_pan_finish():
	if _block_states.has("PanCamera"):
		_block_states['PanCamera'] = BlockStates.Finished
	

func _on_popup_finished(pop_up_key:String):
	if LOGGING: print("PopUp Finished: " + pop_up_key)
	if _block_states.has(pop_up_key):
		_block_states[pop_up_key] = BlockStates.Finished

func _on_custom_block_finished(block_id:String):
	if LOGGING: print("Custom Block: " + block_id)
	if _block_states.has(block_id):
		_block_states[block_id] = BlockStates.Finished
	if _custom_blocks.has(block_id):
		_custom_blocks[block_id].finished.disconnect(_on_custom_block_finished)
		_custom_blocks.erase(block_id)

func _on_next_button_pressed():
	if _state == STATES.WaitingForNextButton:
		_state = STATES.Playing

func _on_question_answered(answer_val:String):
	if LOGGING: print("Set Question Flag: %s" % [answer_val] )
	var tokens = answer_val.split(":")
	var flag_name = tokens[0]
	var flag_val = tokens[1]
	_condition_flags[flag_name] = flag_val

func _on_text_input(val:String):
	_block_states["TextInput"] = BlockStates.Finished
	var set_flag = _last_block_data.get("SetFlag", null)
	if set_flag:
		StoryState.set_story_flag(set_flag, val)

func force_positions(force_pos_data:Dictionary):
	for actor_id in force_pos_data.keys():
		var path_marker_name = force_pos_data[actor_id]
		actor_id = translate_actor_id(actor_id)
		var game_state = CombatRootControl.Instance.GameState
		
		if path_marker_name == "_DEAD_":
			var actor = game_state.get_actor(actor_id, true)
			if actor and not actor.is_dead:
				CombatRootControl.Instance.kill_actor(actor)
		elif path_marker_name == "Hidden":
			var actor = game_state.get_actor(actor_id, true)
			if actor and not actor.is_dead:
				CombatRootControl.Instance.remove_actor(actor)
			
		else:
			var path_marker = CombatRootControl.Instance.MapController.get_path_marker(path_marker_name)
			if !path_marker:
				printerr("force_positions: Failed to find Path Marker: %s" %[path_marker_name])
				continue
			
			## HACK
			if !actor_id or actor_id.begins_with("@"):
				continue
			if actor_id == "_Camera":
				var pos = path_marker.get_last_pos()
				CombatRootControl.Instance.camera.snap_to_map_pos(pos)
				continue
			var actor = game_state.get_actor(actor_id, true, false)
			if not actor:
				actor = ActorLibrary.get_actor(actor_id)
				if actor_id :
					CombatRootControl.Instance.add_actor(actor, path_marker.get_last_pos())
			else:
				game_state.set_actor_pos(actor, path_marker.get_last_pos())
		#var actor_node = CombatRootControl.get_actor_node(actor_id)
		#if !actor_node:
			#printerr("force_positions: Failed to find actor_node for Target Actor: %s" %[actor_id])
			#return false
		#actor_node.set_map_pos(path_marker.get_last_pos())

## Returns true if actor was found and queued for movement
func _do_move_actor(block_data)->bool:
	if block_data.has("StopLoopingActors"):
		for actor_id in block_data.get("StopLoopingActors"):
			var actor_node = CombatRootControl.get_actor_node(actor_id)
			if !actor_node:
				printerr("DialogController: MoveActor failed to find actor_node for Target Actor: %s" %[actor_id])
			else:
				actor_node._moving_in_loop = false
		return false
	var target_actor_id = block_data.get("TargetActorId", null)
	if !target_actor_id:
		printerr("DialogController: No 'TargetActorId' provided on MoveActor block.")
		return false
	target_actor_id = translate_actor_id(target_actor_id)

	var path_marker_name = block_data.get("PathMarkerName", null)
	if !path_marker_name:
		printerr("DialogController: No 'PathMarkerName' provided on MoveActor block.")
		return false
	var actor_node = CombatRootControl.get_actor_node(target_actor_id)
	if !actor_node:
		printerr("DialogController: MoveActor failed to find actor_node for Target Actor: %s" %[target_actor_id])
		return false
	var path_marker = CombatRootControl.Instance.MapController.get_path_marker(path_marker_name)
	if !path_marker:
		printerr("DialogController: MoveActor failed to find Path Marker: %s" %[path_marker_name])
		return false
	
	var path_poses = path_marker.get_path_poses()
	var path_data = []
	
	var actor_pos = actor_node.cur_map_pos
	for path_pos in path_poses:
		var distance = max(abs(actor_pos.x - path_pos.x), abs(actor_pos.y - path_pos.y) )
		var frames = max(1, distance * ActionQueController.FRAMES_PER_ACTION)
		path_data.append({
			"Pos": path_pos,
			"Frames": frames,
			"Speed": block_data.get("Speed", 1)
		})
		actor_pos = path_pos
		
	if path_marker.is_loop:
		path_data[-1]['End'] = true
		actor_node.set_scripted_movement_loop(path_data)
	else:
		actor_node.que_scripted_movement(path_data)
	return true

func translate_actor_id(actor_id:String)->String:
	if actor_id == "Player1":
		actor_id = StoryState.get_player_id(0)
	elif actor_id == "Player2":
		actor_id = StoryState.get_player_id(1)
	elif actor_id == "Player3":
		actor_id = StoryState.get_player_id(2)
	elif actor_id == "Player4":
		actor_id = StoryState.get_player_id(3)
	return actor_id
