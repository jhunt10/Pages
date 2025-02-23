class_name DialogCondition_WaitForNodeFreed
extends BaseDialogConditionWatcher

var watch_node

func _on_create():
	var target_npde_path = _data.get("TargetNode", null)
	if !target_npde_path:
		printerr("DialogCondition_WaitForNodeFreed: No \"TargetNode\" provided.")
		_is_finished = true
		return
	
	watch_node = _dialog_controller.scene_root.get_node(target_npde_path)
	

func is_finished()->bool:
	return watch_node == null or not is_instance_valid(watch_node)
