class_name PopUpMessageControl
extends VBoxContainer

@export var message_box:RichTextLabel

func set_dialog_block(block:PopUpBoxDialogBlock):
	message_box.text = ''
	var lines = block.get_block_data().get("Lines", [])
	for line:String in lines:
		if line.begins_with("@Image|"):
			var image_path = line.trim_prefix("@Image|")
			var image = load(image_path)
			if image:
				message_box.add_image(image)
		else:
			message_box.append_text(line)
