@tool
class_name BounceTextControl
extends HBoxContainer

@export var premade_bounce_letter:BounceLetterControl


@export var bounce_scale:float = 1:
	set(val):
		bounce_scale = val
		if premade_bounce_letter:
			for child in get_children():
				if child is BounceLetterControl:
					child.bounce_scale = val
		
@export var speed_scale:float = 10:
	set(val):
		speed_scale = val
		if premade_bounce_letter:
			for child in get_children():
				if child is BounceLetterControl:
					child.speed_scale = val

@export var display_text:String:
	set(val):
		display_text = val
		var index = 0
		var total_width = 0
		for child in get_children():
			if child == premade_bounce_letter:
				continue
			if index > display_text.length() -1:
				child.queue_free()
			else:
				child.set_letter(display_text.substr(index, 1))
				total_width += child.get_minimum_size().x
				index += 1
		while index < display_text.length():
			var new_letter:BounceLetterControl = premade_bounce_letter.duplicate()
			#new_letter.label.text = 
			#var min_size = new_letter.label.get_minimum_size()
			#new_letter.custom_minimum_size = min_size
			#new_letter.size = min_size
			new_letter.set_letter(display_text.substr(index, 1))
			self.add_child(new_letter)
			new_letter.show()
			total_width += new_letter.get_minimum_size().x
			new_letter.timer = -total_width
			index += 1
			#print("%s:%s" % [new_letter.get_minimum_size(), new_letter.label.text])
		#letters_container.size = get_minimum_size()
		#self.size.x = total_width

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not Engine.is_editor_hint():
		premade_bounce_letter.label.text = ""
		premade_bounce_letter.hide()
	pass # Replace with function body.
