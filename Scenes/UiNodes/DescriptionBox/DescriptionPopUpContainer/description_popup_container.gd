class_name DecscriptionPopUpContainer
extends Control

@export var back_patch:BackPatchContainer
@export var message_box:RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if self.visible:
		self.global_position = self.get_global_mouse_position() - Vector2(0, 8)
	pass

func set_text(text:String):
	var text_size = message_box.get_theme_font("normal_font").get_string_size(text)
	if text_size.x > 250:
		message_box.custom_minimum_size.x = 250
		message_box.autowrap_mode = TextServer.AUTOWRAP_WORD
	else:
		message_box.custom_minimum_size.x = 0
		message_box.autowrap_mode = TextServer.AUTOWRAP_OFF
	message_box.clear()
	message_box.append_text(text)
