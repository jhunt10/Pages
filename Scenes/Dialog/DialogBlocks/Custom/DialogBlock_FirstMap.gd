class_name FirstMapConditionDialogBlock
extends BaseDialogBlock

var next_tag

func _init(parent, data)->void:
	data['WaitForButton'] = false
	super(parent, data)


func update(delta: float) -> void:
	pass

func do_thing():
	if _block_data.keys().has("ReturnToMainMenu"):
		MainRootNode.Instance.go_to_main_menu()
		self.finish()
		return
