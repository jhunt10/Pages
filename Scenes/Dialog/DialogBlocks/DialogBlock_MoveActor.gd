class_name MoveActorDialogBlock
extends BaseDialogBlock

var name:String
func _init(parent, data)->void:
	data['WaitForButton'] = false
	super(parent, data)

var actor_node:ActorNode

func do_thing():
	var target_id = _block_data.get("TargetActorId", '')
	if target_id == "Player1":
		target_id = StoryState.get_player_id()
	var target_actor = ActorLibrary.get_actor(target_id)
	if !target_actor:
		printerr("MoveActorDialogBlock: Failed to find Target Actor: %s" %[target_id])
		self.finish()
		return
	actor_node = CombatRootControl.get_actor_node(target_id)
	if !actor_node:
		printerr("MoveActorDialogBlock: Failed to find actor_node for Target Actor: %s" %[target_id])
		self.finish()
		return
	
	var marker_pos_name = _block_data.get('PosMarkerName', null)
	var marker_path_name = _block_data.get('PathMarkerName', null)
	if marker_pos_name:
		_do_pose_marker(target_actor, actor_node, marker_pos_name)
	elif marker_path_name:
		_do_path_marker(target_actor, actor_node, marker_path_name)
	else:
		printerr("MoveActorDialogBlock: Failed to find 'PosMarkerName' or 'PathMarkerName'.")
		self.finish()
		return
	
	if _block_data.get('FollowActor', false):
		CombatRootControl.Instance.camera.lock_to_actor(target_actor)
	elif (CombatRootControl.Instance.camera.following_actor_node and 
		CombatRootControl.Instance.camera.following_actor_node.Actor.Id == target_id):
		CombatRootControl.Instance.camera.following_actor_node = null
		
		
	if _block_data.get('WaitToFinish', true) and actor_node.is_moving:
		actor_node.reached_motion_destination.connect(on_move_finsh)
	else:
		self.finish()
	
func _do_pose_marker(actor, actor_node, marker_name):
	var marker_pos = CombatRootControl.Instance.MapController.get_pos_marker(marker_name)
	if !marker_pos:
		printerr("MoveActorDialogBlock: Failed to find Marker Pos: %s" %[marker_name])
		self.finish()
		return
	var actor_pos = actor_node.cur_map_pos
	var distance = max(abs(actor_pos.x - marker_pos.x), abs(actor_pos.y - marker_pos.y) )
	var frames = (distance) * ActionQueController.FRAMES_PER_ACTION
	var speed = _block_data.get("SpeedScale", 1)
	var path_data = []
	path_data.append({
			"Pos": marker_pos,
			"Frames": frames,
			"Speed": speed
		})
	actor_node.que_scripted_movement(path_data)

func _do_path_marker(actor_node, path_marker):
	var path_poses = path_marker.get_path_poses()
	var path_data = []
	
	var actor_pos = actor_node.cur_map_pos
	for path_pos in path_poses:
		var distance = max(abs(actor_pos.x - path_pos.x), abs(actor_pos.y - path_pos.y) )
		var frames = max(1, distance * ActionQueController.FRAMES_PER_ACTION)
		var speed = _block_data.get("SpeedScale", 1)
		path_data.append({
			"Pos": path_pos,
			"Frames": frames,
			"Speed": speed
		})
		actor_pos = path_pos
	actor_node.que_scripted_movement(path_data)
	pass

func finish():
	super()
	print("Moce Actor Block Finished " + name)
	if actor_node.reached_motion_destination.is_connected(on_move_finsh):
		actor_node.reached_motion_destination.disconnect(on_move_finsh)

func on_move_finsh():
	print("Move Actor Finished " + name)
	self.finish()

func on_skip():
	pass
