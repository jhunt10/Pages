class_name PageDescControl
extends NinePatchRect

@onready var page_image:TextureRect = $PageImageBack/TextureRect
@onready var name_label:Label = $NameLabel
@onready var tags_label:Label = $TagsLabel
@onready var description_box:RichTextLabel = $CharacterPortraitRect2/RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_page(action:BaseAction):
	page_image.texture = action.get_large_sprite()
	name_label.text = action.DisplayName
	tags_label.text = "Tags: "
	var first = true
	for tag in action.Tags:
		if not first: tags_label.text += ", "
		else: first = false
		tags_label.text += tag
	description_box.text = action.Description
