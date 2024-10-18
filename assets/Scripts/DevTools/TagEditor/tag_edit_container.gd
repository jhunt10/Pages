@tool
class_name TagEditContainer
extends BackPatchContainer

@export var tag_entry_container:TagEditEntryContainer
@export var tags_container:FlowContainer

@onready var add_button:Button = $InnerContainer/TitleContainer/AddButton

var get_required_tags:Callable

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	add_button.pressed.connect(add_entry)
	tag_entry_container.visible = false

func load_optional_tags(tags:Array):
	_build_tags_list(tags)
	
func _build_tags_list(optional_tags:Array):
	print("Tag Edit Load List; %s" % [optional_tags])
	for child in tags_container.get_children():
		child.queue_free()
	if get_required_tags:
		var required_tags = get_required_tags.call()
		for tag in required_tags:
			_create_tag_entry(tag, false)
	for tag in optional_tags:
		_create_tag_entry(tag, true)

func add_entry():
	_create_tag_entry('', true)

func _create_tag_entry(tag:String, editable:bool):
	var new_entry:TagEditEntryContainer = tag_entry_container.duplicate()
	new_entry.set_text(tag, editable)
	new_entry.visible = true
	tags_container.add_child(new_entry)

func get_tags(optional_only:bool=false)->Array:
	var out_list = []
	for tag_entry:TagEditEntryContainer in tags_container.get_children():
		if optional_only and tag_entry._editable:
			out_list.append(tag_entry.get_text())
		elif not optional_only:
			out_list.append(tag_entry.get_text())
	return out_list

func lose_focus_if_has():
	for tag_entry:TagEditEntryContainer in tags_container.get_children():
		tag_entry.lose_focus_if_has()
