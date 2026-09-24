class_name BaseCustomDialogBlock

@warning_ignore("unused_signal")
signal finished

## Returns true if block should be waitied on
func handle_block(_dialog_control:DialogController, _block_data:Dictionary)->bool:
	return false
