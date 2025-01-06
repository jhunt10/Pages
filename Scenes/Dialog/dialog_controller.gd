class_name DialogController
extends Control

enum STATES {Ready, Playing, WaitingForBlocks, WaitingForNextButton, WaitingForCondition, Finished}

enum BlockTypes {
	Delay, 
	SetFlag, 
	SpeechBox, 
	MoveActor, 
	Blackout, 
	PanCamera, 
	PopUp,
	ClearQue, 
	SpawnActor,
	CustomBlock
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


var _condition_flags:Dictionary={}
var _condition_watcher:BaseDialogConditionWatcher
var _custom_blocks:Dictionary = {}

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
						_state = STATES.Playing
					else:
						next_button.show()
				else:
					next_button.hide()

enum BlockStates {Playing, WaitingForNextButton, Finished}
## Mapping of block_id to is_finished
var _block_states:Dictionary

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
			print("Delay TImer: %s" % [_delay_timer])
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
				_state = STATES.Finished
				self.queue_free()

## Returns true if any blocks are currently playing
func _are_blocks_playing():
	var is_playing = false
	for key in _block_states.keys():
		if _block_states[key] == BlockStates.Playing:
			is_playing = true
		else:
			_block_states.erase(key)
	return is_playing

## Returns true if any block is waiting for the "Next" button
func _are_blocks_waiting_for_next_button():
	var is_playing = false
	for key in _block_states.keys():
		if _block_states[key] == BlockStates.WaitingForNextButton:
			is_playing = true
		else:
			_block_states.erase(key)
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
		if StoryState.story_flags.has(flag_name):
			var flag_val = StoryState.story_flags.get(flag_name)
			var cases  = next_part_logic.get("Cases", {})
			if cases.has(flag_val):
				return cases[flag_val]
	return _current_part_data.get("_NextPartKey", null)

func _start_part(part_key:String):
	print("Starting  part: " + part_key)
	_part_start_timer = 0
	_cur_part_key = part_key
	_condition_watcher = null
	if not _dialog_part_datas.has(part_key):
		printerr("DialogControl: No script part found with key '%s'." % [part_key])
		_state = STATES.Finished
		self.queue_free()
		return
	_current_part_data = _dialog_part_datas[part_key].duplicate(true)
	if not _current_part_data.keys().has('Blocks'):
		_current_part_data['Blocks'] = []
		
	if _current_part_data.has("EnsurePoses"):
		var force_poses = _current_part_data['EnsurePoses']
		force_positions(force_poses)
	
	if _current_part_data.get("Inital_BlackOutState", null):
		blackout_control.set_state_string(_current_part_data['Inital_BlackOutState'])
	
	if _current_part_data.get("AllowInputThrough", false):
		input_blocker.hide()
	else:
		input_blocker.show()
	
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

## Returns true if block should be waitied on
func _handle_block(block_data:Dictionary)->bool:
	var block_type_str = block_data.get("BlockType", '')
	if block_type_str == "MainMenu":
		MainRootNode.Instance.go_to_main_menu()
		return true
	print("Handeling Block: " + block_type_str)
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
		if new_block.handle_block(block_data):
			var new_id = str(ResourceUID.create_id())
			new_block.finished.connect(_on_custom_block_finished.bind(new_id))
			_custom_blocks[new_id] = new_block
			return true
		return false
	
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
	if block_type == BlockTypes.Delay:
		var flag_name = block_data.get("FlagName", null)
		if !flag_name:
			return false
		var val = block_data.get("Value", null)
		_condition_flags[flag_name] =  val
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
			_block_states['Speech'] = BlockStates.Playing
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
			if actor_id == "Player1":
				actor_id = StoryState.get_player_id()
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
	#----------------------------------
	if block_type == BlockTypes.Blackout:
		var blackout_state = block_data.get("BlackOutState", null)
		if blackout_state == null:
			printerr("DialogController: No 'BlackOutState' provided on BlackOut block.")
			blackout_state = "Clear"
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
			if target_actor_id == "Player1":
				target_actor_id = StoryState.get_player_id()
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
		print("DialogBlock: Spawing Actor %s" %[Time.get_unix_time_from_system()])
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
			CombatRootControl.Instance.add_actor(new_actor, 1, actor_pos)
	return false
func load_dialog_script(file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	var text:String = file.get_as_text()
	_condition_watcher = null
	_dialog_part_datas = JSON.parse_string(text)
	if not _dialog_part_datas.keys().has("_MetaData_"):
		printerr("No _MetaData_ found in dialog script.")
		_dialog_part_datas.clear()
		self.queue_free()
		return
	var start_part_key = _dialog_part_datas["_MetaData_"].get("StartPartKey", null)
	if !start_part_key:
		printerr("No 'StartPartKey' found in _MetaData_ of dialog script.")
		_dialog_part_datas.clear()
		self.queue_free()
		return
	_cur_part_key = start_part_key
	_start_part(_cur_part_key)

func _on_speech_box_finished(is_top:bool):
	print("Speech Box Finished")
	if _block_states.has("Speech"):
		_block_states['Speech'] = BlockStates.Finished

func _on_blackout_finished():
	print("BlackOut Finished")
	if _block_states.has("BlackOut"):
		_block_states["BlackOut"] = BlockStates.Finished

func _on_actor_move_finished(actor_id):
	var move_key = actor_id+":Move"
	if _block_states.has(move_key):
		_block_states[move_key] = BlockStates.Finished
	var camera = CombatRootControl.Instance.camera
	if (camera.following_actor_node and  camera.following_actor_node.Actor.Id == actor_id):
		camera.following_actor_node = null
		var actor_node = CombatRootControl.get_actor_node(actor_id)
		camera.snap_to_map_pos(actor_node.cur_map_pos)

func _on_camera_pan_finish():
	if _block_states.has("PanCamera"):
		_block_states['PanCamera'] = BlockStates.Finished
	

func _on_popup_finished(pop_up_key:String):
	print("PopUp Finished: " + pop_up_key)
	if _block_states.has(pop_up_key):
		_block_states[pop_up_key] = BlockStates.Finished

func _on_custom_block_finished(block_id:String):
	print("Custom Block: " + block_id)
	if _block_states.has(block_id):
		_block_states[block_id] = BlockStates.Finished
	if _custom_blocks.has(block_id):
		_custom_blocks[block_id].finished.disconnect(_on_custom_block_finished)
		_custom_blocks.erase(block_id)

func _on_next_button_pressed():
	if _state == STATES.WaitingForNextButton:
		_state = STATES.Playing

func _on_question_answered(answer_val:String):
	print("Set Question Flag: %s" % [answer_val] )
	var tokens = answer_val.split(":")
	var flag_name = tokens[0]
	var flag_val = tokens[1]
	_condition_flags[flag_name] = flag_val

func force_positions(force_pos_data:Dictionary):
	for actor_id in force_pos_data.keys():
		var path_marker_name = force_pos_data[actor_id]
		if actor_id == "Player1":
			actor_id = StoryState.get_player_id()
		var game_state = CombatRootControl.Instance.GameState
		
		if path_marker_name == "_DEAD_":
			var actor = game_state.get_actor(actor_id, true)
			if actor and not actor.is_dead:
				CombatRootControl.Instance.kill_actor(actor)
		else:
			var path_marker = CombatRootControl.Instance.MapController.get_path_marker(path_marker_name)
			if !path_marker:
				printerr("force_positions: Failed to find Path Marker: %s" %[path_marker_name])
				continue
				
			if actor_id == "_Camera":
				var pos = path_marker.get_last_pos()
				CombatRootControl.Instance.camera.snap_to_map_pos(pos)
				continue
			var actor = game_state.get_actor(actor_id)
			if not actor:
				actor = ActorLibrary.get_actor(actor_id)
				CombatRootControl.Instance.add_actor(actor, 1, path_marker.get_last_pos())
			else:
				game_state.MapState.set_actor_pos(actor, path_marker.get_last_pos())
		#var actor_node = CombatRootControl.get_actor_node(actor_id)
		#if !actor_node:
			#printerr("force_positions: Failed to find actor_node for Target Actor: %s" %[actor_id])
			#return false
		#actor_node.set_map_pos(path_marker.get_last_pos())

## Returns true if actor fas found and queued for movement
func _do_move_actor(block_data)->bool:
	var target_actor_id = block_data.get("TargetActorId", null)
	if !target_actor_id:
		printerr("DialogController: No 'TargetActorId' provided on MoveActor block.")
		return false	
	if target_actor_id == "Player1":
		target_actor_id = StoryState.get_player_id()

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
	actor_node.que_scripted_movement(path_data)
	return true
