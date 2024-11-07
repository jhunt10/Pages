@tool
class_name PageDetailsContainer
extends BackPatchContainer

@export var name_label:Label
@export var tags_label:Label
@export var description_label:RichTextLabel

func set_page(page:BaseAction):
	name_label.text = page.details.display_name
	tags_label.text = "Tags: " + JSON.stringify(page.details.tags)
	description_label.text = page.details.description
