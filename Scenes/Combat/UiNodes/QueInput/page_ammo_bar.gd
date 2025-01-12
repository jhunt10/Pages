@tool
class_name PageAmmoBar
extends Container

@export var premade_bar:Control
@export var top_bar_texture:Texture2D
@export var mid_bar_texture:Texture2D
@export var bot_bar_texture:Texture2D

@export var color:Color
@export var current_val:int:
	set(val):
		current_val = val
		sync = true
@export var clip_val:int:
	set(val):
		clip_val = val
		sync = true
@export var cost_val:int:
	set(val):
		cost_val = val
		sync = true

@export var sync:bool:
	set(val):
		printerr("Sync Ammo Bar: %s / %s || %s " % [cost_val, clip_val, current_val])
		if not premade_bar:
			return
		var count = clip_val / max(cost_val, 1)
		if self.get_child_count() != count +1:
			for child in self.get_children():
				if not child == premade_bar:
					child.queue_free()
			bar_parts = []
			var total_size = self.custom_minimum_size.y
			var bar_size = (total_size / (float(max(clip_val, 1)) / float(max(cost_val, 1)))) + 1
			var remainder = clip_val - (count * cost_val)
			premade_bar.hide()
			#premade_bar.custom_minimum_size.y = bar_size
			for index in range(count):
				var new_bar:Control = premade_bar.duplicate()
				if index == 0:
					new_bar.get_child(0).texture = top_bar_texture
				elif index == count -1 and remainder == 0:
					new_bar.get_child(0).texture = bot_bar_texture
				else:
					new_bar.get_child(0).texture = mid_bar_texture
				new_bar.custom_minimum_size.y = bar_size
				new_bar.size.y = bar_size
				new_bar.modulate = color
				new_bar.show()
				print("BarSize: " + str(bar_size))
				self.add_child(new_bar)
				bar_parts.append(new_bar)
			if remainder > 0:
				var remainder_size = total_size - (bar_size * count) + count
				print("RemainderSize: " + str(remainder_size))
				var remainder_bar:Control = premade_bar.duplicate()
				remainder_bar.get_child(0).texture = bot_bar_texture
				remainder_bar.custom_minimum_size.y = remainder_size
				remainder_bar.size.y = remainder_size
				remainder_bar.modulate = color
				remainder_bar.show()
				self.add_child(remainder_bar)
				bar_parts.append(remainder_bar)
		var temp_val = current_val
		for index in range(bar_parts.size()):
			var reverse_index = bar_parts.size() - index - 1
			if temp_val < cost_val:
				bar_parts[reverse_index].get_child(0).hide()
			else:
				bar_parts[reverse_index].get_child(0).show()
			temp_val -= cost_val


var bar_parts = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sync = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
