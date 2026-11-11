class_name DecscriptionPopUpContainer
extends Control

@export var back_patch:BackPatchContainer
@export var close_button:TextureButton
@export var description_box:DescriptionBox

var parent_description_box:DescriptionBox
var mouse_start_pos = null

var mouse_move_limit = 50
var pinned = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close_button.hide()
	close_button.pressed.connect(queue_free)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if self.visible and not pinned:
		var screen_size = get_viewport_rect().size
		var popup_size = back_patch.get_global_rect().size
		var mouse_pos = self.get_global_mouse_position()
		if !mouse_start_pos:
			mouse_start_pos = mouse_pos
		var self_pos = mouse_pos
		set_screen_safe_position(mouse_pos - Vector2(0, 8))
		### X is haved because we are centered on bottom edge
		## Bound Right
		#if self_pos.x - (popup_size.x) < 0:
			#self_pos.x = 0 - (popup_size.x / 2)
		## Bound Left
		#elif self_pos.x + (popup_size.x /2) > screen_size.x:
			#self_pos.x = screen_size.x - (popup_size.x/2)
			#
		##Bound Top
		#if self_pos.y - popup_size.y - 8 < 0:
			#self_pos.y = popup_size.y
		# Bound Bottom ( Not Posiible since always above point)
		#elif self_pos.y + (popup_size.y / 2) > screen_size.y:
			#self_pos.y = screen_size.y - (popup_size.y / 2)
		#self.global_position = self_pos - Vector2(0, 8)
		
		if mouse_start_pos:
			var mouse_moved = mouse_pos.distance_to(mouse_start_pos)
			if mouse_moved > mouse_move_limit:
				if parent_description_box:
					parent_description_box._hide_pop_up({})
	pass

func set_text(text:String):
	var text_size = description_box.get_theme_font("normal_font").get_string_size(text)
	if text_size.x > 250:
		description_box.custom_minimum_size.x = 250
		description_box.autowrap_mode = TextServer.AUTOWRAP_WORD
	else:
		description_box.custom_minimum_size.x = 0
		description_box.autowrap_mode = TextServer.AUTOWRAP_OFF
	description_box.clear()
	description_box.append_text(text)
	close_button.hide()
	pinned = false

func set_description(
	raw_description:String, 
	object_def:Dictionary = {}, 
	object_inst:BaseLoadObject = null, 
	actor:BaseActor = null
	):
	description_box.clear()
	description_box.set_description(raw_description, object_def, object_inst, actor)
	close_button.hide()
	pinned = false

func pin_in_place():
	pinned = true
	close_button.show()

func set_screen_safe_position(pos):
	var self_rec = get_rect()
	var screen_rect = get_viewport_rect().size
	if pos.x < 0: 
		pos.x = 0
	if pos.x > screen_rect.x - self_rec.size.x:
		pos.x = screen_rect.x - self_rec.size.x
	if pos.y < 0: 
		pos.y = 0
	if pos.y > screen_rect.y - self_rec.size.y:
		pos.y = screen_rect.y - self_rec.size.y
	self.global_position = pos
