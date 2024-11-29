class_name PanCameraDialogBlock
extends BaseDialogBlock

var name:String
func _init(parent, data)->void:
	data['WaitForButton'] = false
	super(parent, data)

func do_thing():
	var target_type:String = _block_data.get("TargetType")
	CombatRootControl.Instance.camera.panning_finished.connect(on_pan_finish)
	if target_type == "MapPos":
		var map_pos_arr:Array = _block_data.get("TargetMapPos")
		var map_pos = MapPos.new(map_pos_arr[0], map_pos_arr[1], 0, 0)
		CombatRootControl.Instance.camera.start_auto_pan_to_map_pos(map_pos)
		name = "To Pos: %s" % [map_pos]
	elif target_type == "Actor":
		var actor_id:String = _block_data.get("TargetActorId")
		var actor = ActorLibrary.get_actor(actor_id)
		if actor == null:
			printerr("PanCameraDialogBlock: Failed to find Target Actor: %s" %[actor_id])
			
			self.finish()
			return
		CombatRootControl.Instance.camera.start_auto_pan_to_actor(actor)
		name = "To Actor: %s" % [actor_id]
	else:
		printerr("PanCameraDialogBlock: Unknown Target Type: %s" %[target_type])
		self.finish()
		return
	print("Pan Block Started " + name)

func finish():
	super()
	print("Pan Block Finished " + name)
	if CombatRootControl.Instance.camera.panning_finished.is_connected(on_pan_finish):
		CombatRootControl.Instance.camera.panning_finished.disconnect(on_pan_finish)

func on_pan_finish():
	print("Pan Finished " + name)
	self.finish()

func on_skip():
	print("Skipping Paning " + name)
	CombatRootControl.Instance.camera.force_finish_panning()
