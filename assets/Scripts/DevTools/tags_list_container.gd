class_name TagListEditControl
extends FlowContainer

@onready var add_button:TextureButton = $AddTagButton
@onready var premade_tag_input:TagInputContainer = $TagInputControl
var tags_inputs = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	premade_tag_input.visible = false
	add_button.pressed.connect(_create_new_tag.bind('', true))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _create_new_tag(tag:String = '', grab_focus=false):
	var new_tag:TagInputContainer = premade_tag_input.duplicate()
	self.add_child(new_tag)
	new_tag.visible = true
	if tag != '':
		new_tag.set_tag(tag)
	tags_inputs.append(new_tag)
	if grab_focus:
		new_tag.text_input.grab_focus()

func set_tags(tags:Array):
	for tag in tags_inputs:
		tag.queue_free()
	tags_inputs.clear()
	for tag in tags:
		_create_new_tag(tag)
