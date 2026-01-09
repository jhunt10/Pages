class_name DecscriptionPopUpContainer
extends Control

@export var back_patch:BackPatchContainer
@export var message_box:RichTextLabel

var parent_description_box:DescriptionBox
var mouse_start_pos = null

var mouse_move_limit = 50

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if self.visible:
		var screen_size = DisplayServer.window_get_size()
		var popup_size = back_patch.size
		var mouse_pos = self.get_global_mouse_position()
		if !mouse_start_pos:
			mouse_start_pos = mouse_pos
		var self_pos = mouse_pos
		# Bound Right
		if self_pos.x - (popup_size.x / 2) < 0:
			self_pos.x = 0 - (popup_size.x / 2)
		# Bound Left
		elif self_pos.x + (popup_size.x / 2) > screen_size.x:
			self_pos.x = screen_size.x - (popup_size.x / 2)
			
		#Bound Top
		if self_pos.y - popup_size.y - 8 < 0:
			self_pos.y = popup_size.y
		# Bound Bottom ( Not Posiible since always above point)
		#elif self_pos.y + (popup_size.y / 2) > screen_size.y:
			#self_pos.y = screen_size.y - (popup_size.y / 2)
		self.global_position = self_pos - Vector2(0, 8)
		
		if mouse_start_pos:
			var mouse_moved = mouse_pos.distance_to(mouse_start_pos)
			if mouse_moved > mouse_move_limit:
				if parent_description_box:
					parent_description_box._hide_pop_up({})
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
