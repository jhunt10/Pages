class_name TagInputContainer
extends Control

const PADDING:int = 4

@onready var container:HBoxContainer = $HBoxContainer
@onready var text_input:SelfScalingLineEdit = $HBoxContainer/LineEdit
@onready var delete_button:TextureButton = $HBoxContainer/XButton

var need_resize = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	container.resized.connect(_resize)
	delete_button.pressed.connect(on_delete)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_delete():
	get_parent().delete_tag_node(self)
	self.queue_free()

func _resize():
	self.custom_minimum_size = Vector2i(container.size.x + (2 * PADDING), container.size.y + (2 * PADDING))
	var parent = self.get_parent()
	if parent and parent is FlowContainer:
		var flow = parent as FlowContainer
		flow.queue_sort()

func set_tag(tag:String):
	text_input.text = tag
	text_input._sync_size()
