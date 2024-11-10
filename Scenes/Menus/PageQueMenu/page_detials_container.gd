@tool
class_name PageDetailsContainer
extends BackPatchContainer

@export var name_label:Label
@export var tags_label:Label
@export var description_label:RichTextLabel

func set_page(page:BaseAction):
	name_label.text = page.details.display_name
	var tags_string = ''
	var first = false
	for tag in page.details.tags:
		tags_string += tag + ", "
	tags_label.text = "Tags: " + tags_string.trim_suffix(", ")
	description_label.text = page.details.description
