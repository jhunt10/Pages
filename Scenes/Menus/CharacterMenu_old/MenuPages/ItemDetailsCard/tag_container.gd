@tool
class_name TagsContainer
extends BoxContainer

@export var show_all:bool

@export var premade_tag:DescriptionBox
@export var tags_container:FlowContainer

@export var tags_show_hide_button:Button
@export var tags_title_container:BoxContainer
@export var tags_plus_minus_icon:TextureRect
@export var tags_plus_texture:Texture2D
@export var tags_minus_texture:Texture2D

var set_show_on_next_process:bool = false

func _ready() -> void:
	tags_show_hide_button.pressed.connect(toggle_show_hide)
	premade_tag.hide()

func _process(_delta: float) -> void:
	if set_show_on_next_process:
		set_show_on_next_process = false
		set_show_hide(show_all)

func set_tags(tags:Array):
	for child in tags_container.get_children():
		if child == tags_title_container:
			continue
		if child == premade_tag:
			continue
		child.queue_free()
	for tag in tags:
		var new_tag_label:DescriptionBox = premade_tag.duplicate()
		new_tag_label.clear()
		new_tag_label.set_description("@@#Tag:"+tag+"@@")
		new_tag_label.show()
		tags_container.add_child(new_tag_label)
	show_all = false
	set_show_on_next_process = true
	

func toggle_show_hide():
	set_show_hide(!show_all)

func set_show_hide(val):
	show_all = val
	if tags_plus_minus_icon:
		if show_all:
			tags_plus_minus_icon.texture = tags_minus_texture
		else:
			tags_plus_minus_icon.texture = tags_plus_texture
	for child in tags_container.get_children():
		if child is DescriptionBox:
			if child.position.y > 0:
				child.visible = show_all
