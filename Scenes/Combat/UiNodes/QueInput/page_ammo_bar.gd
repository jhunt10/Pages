@tool
class_name PageAmmoBar
extends Container

@export var premade_bar:Control
@export var top_bar_texture:Texture2D
@export var mid_bar_texture:Texture2D
@export var bot_bar_texture:Texture2D
@export var single_bar_texture:Texture2D

@export var ammo_type:AmmoItem.AmmoTypes:
	set(val):
		ammo_type = val
		sync = true
@export var gen_ammo_color:Color
@export var phy_ammo_color:Color
@export var mag_ammo_color:Color
@export var abn_ammo_color:Color
@export var empty_color:Color

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

var _suppress_sync = false

@export var sync:bool:
	set(val):
		printerr("Sync Ammo Bar: %s / %s || %s " % [cost_val, clip_val, current_val])
		if not premade_bar:
			return
		if _suppress_sync:
			return
		var count = clip_val / max(cost_val, 1)
		if self.get_child_count() != count +1:
			for child in self.get_children():
				if not child == premade_bar:
					child.queue_free()
			bar_parts = []
			#var total_size = self.custom_minimum_size.y
			#var bar_size = (total_size / (float(max(clip_val, 1)) / float(max(cost_val, 1)))) + 1
			#var remainder = clip_val - (count * cost_val)
			premade_bar.hide()
			#premade_bar.custom_minimum_size.y = bar_size
			for index in range(count):
				var new_bar:Control = premade_bar.duplicate()
				if count == 1:
					new_bar.get_child(0).texture = single_bar_texture
				elif index == 0:
					new_bar.get_child(0).texture = top_bar_texture
				elif index == count -1:
					new_bar.get_child(0).texture = bot_bar_texture
				else:
					new_bar.get_child(0).texture = mid_bar_texture
				#new_bar.custom_minimum_size.y = bar_size
				#new_bar.size.y = bar_size
				new_bar.show()
				#print("BarSize: " + str(bar_size))
				self.add_child(new_bar)
				bar_parts.append(new_bar)
			#if remainder > 0:
				#var remainder_size = total_size - (bar_size * count) + count
				#print("RemainderSize: " + str(remainder_size))
				#var remainder_bar:Control = premade_bar.duplicate()
				#remainder_bar.get_child(0).texture = bot_bar_texture
				#remainder_bar.custom_minimum_size.y = remainder_size
				#remainder_bar.size.y = remainder_size
				#if ammo_type == AmmoItem.AmmoTypes.Gen:
					#remainder_bar.modulate = gen_ammo_color
				#elif ammo_type == AmmoItem.AmmoTypes.Mag:
					#remainder_bar.modulate = mag_ammo_color
				#elif ammo_type == AmmoItem.AmmoTypes.Phy:
					#remainder_bar.modulate = phy_ammo_color
				#elif ammo_type == AmmoItem.AmmoTypes.Abn:
					#remainder_bar.modulate = abn_ammo_color
				#remainder_bar.show()
				#self.add_child(remainder_bar)
				#bar_parts.append(remainder_bar)
		var temp_val = current_val
		for index in range(bar_parts.size()):
			var reverse_index = bar_parts.size() - index - 1
			if temp_val < cost_val:
				bar_parts[reverse_index].modulate = empty_color
			else:
				if ammo_type == AmmoItem.AmmoTypes.Gen:
					bar_parts[reverse_index].modulate = gen_ammo_color
				elif ammo_type == AmmoItem.AmmoTypes.Mag:
					bar_parts[reverse_index].modulate = mag_ammo_color
				elif ammo_type == AmmoItem.AmmoTypes.Phy:
					bar_parts[reverse_index].modulate = phy_ammo_color
				elif ammo_type == AmmoItem.AmmoTypes.Abn:
					bar_parts[reverse_index].modulate = abn_ammo_color
			temp_val -= cost_val


var bar_parts = []

func set_ammo_data(ammo_data:Dictionary):
	_suppress_sync = true
	ammo_type = AmmoItem.AmmoTypes.get(ammo_data.get("AmmoType", "Gen"))
	clip_val = ammo_data.get("Clip", 1)
	cost_val = ammo_data.get("Cost", 1)
	_suppress_sync = false
