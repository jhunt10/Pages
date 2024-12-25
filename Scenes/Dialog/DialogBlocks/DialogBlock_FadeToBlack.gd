class_name FadeToBlackDialogBlock
extends BaseDialogBlock

var name:String
func _init(parent, data)->void:
	data['WaitForButton'] = false
	super(parent, data)

var actor_node:ActorNode

func do_thing():
	var fade_in = _block_data.get("FadeIn", null)
	if fade_in:
		_parent_dialog_control.blackout_coontrol.fade_to_black = false
	var fade_out = _block_data.get("FadeOut", null)
	if fade_out:
		_parent_dialog_control.blackout_coontrol.fade_to_black = true
	self.finish()
	return

func on_skip():
	pass
