@tool
class_name PageDetailsContainer
extends BackPatchContainer

@export var name_label:Label
@export var tags_label:Label
@export var description_label:RichTextLabel
@export var range_display:MiniRangeDisplay

func set_page(page:BaseAction):
	name_label.text = page.get_display_name()
	var tags_string = ''
	for tag in page.details.tags:
		tags_string += tag + ", "
	tags_label.text = "Tags: " + tags_string.trim_suffix(", ")
	description_label.text = page.get_description()
	range_display.visible = false
	if page.has_preview_target():
		var preview_params = page.get_preview_target_params(null)
		if preview_params:
			range_display.visible = true
			range_display.load_area_matrix(preview_params.target_area)
