class_name BaseCustomDialogBlock

signal finished

## Returns true if block should be waitied on
func handle_block(_dialog_control:DialogController, _block_data:Dictionary)->bool:
	return false
