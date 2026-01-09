class_name TagBox
extends DescriptionBox

func set_tags(tags:Array):
	self.clear()
	var line = ""
	for tag in tags:
		for sub_line in _parse_tag_info(["Tag", tag]):
			line += sub_line + "  "
	line.trim_suffix("  ")
	self.append_text(line)
