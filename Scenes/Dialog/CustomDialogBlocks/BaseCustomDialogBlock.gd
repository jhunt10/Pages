class_name BaseCustomDialogBlock

signal finished

## Returns true if block should be waitied on
func handle_block(dialog_control:DialogController, block_data:Dictionary)->bool:
	return false
