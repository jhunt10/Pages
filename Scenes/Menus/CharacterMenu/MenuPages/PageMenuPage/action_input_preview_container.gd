class_name ActionInputPreviewContainer
extends HBoxContainer

@export var edit_button:TextureRect
@export var spacer:VSeparator
@export var premade_page_icon:TextureRect

func set_actor(actor:BaseActor):
	#TODO: Speedup
	for child in get_children():
		if child == edit_button or child == premade_page_icon or child == spacer:
			continue
		child.queue_free()
	premade_page_icon.hide()
	var slot_count = 0
	for action:BaseAction in actor.pages.list_actions():
		var new_icon = premade_page_icon.duplicate()
		new_icon.get_child(0).texture = action.get_small_page_icon(actor)
		new_icon.show()
		self.add_child(new_icon)
		slot_count += 1
	self.remove_child(spacer)
	self.remove_child(edit_button)
	self.add_child(spacer)
	self.add_child(edit_button)
	if slot_count >= 9:
		spacer.hide()
		edit_button.hide()
	else:
		spacer.show()
		edit_button.show()
