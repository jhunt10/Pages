@tool
class_name BaseFlashTextVfxNode
extends BaseVfxNode

enum FlashTextType {
	Normal_Dmg, Blocked_Dmg, Crit_Dmg, Healing_Dmg, DOT_Dmg,
	NoAmmo, NoTarget, Miss, Evade, Protect, Message
}

@export var flash_text_value:String
@export var flash_text_type:FlashTextType:
	set(val):
		flash_text_type = val
		if label:
			match flash_text_type:
				FlashTextType.Normal_Dmg:
					label.modulate = normal_damage_color
					# Pad with spaces because shadow gets cut off by bounds
					label.text = " "+str(flash_text_value)+" "
					label.add_theme_font_size_override("font_size", default_font_size)
					use_x_velocity = true
				FlashTextType.Blocked_Dmg:
					label.modulate = blocked_damage_color
					label.text = " "+str(flash_text_value)+" "
					label.add_theme_font_size_override("font_size", default_font_size)
					use_x_velocity = true
				FlashTextType.Crit_Dmg:
					label.modulate = crit_damage_color
					label.text = " "+str(flash_text_value)+" "
					label.add_theme_font_size_override("font_size", default_font_size)
					use_x_velocity = true
				FlashTextType.Healing_Dmg:
					label.modulate = healing_damage_color
					label.text = " +"+str(flash_text_value)+" "
					label.add_theme_font_size_override("font_size", default_font_size)
					use_x_velocity = true
				FlashTextType.DOT_Dmg:
					label.modulate = dot_damage_color
					label.text = " "+str(flash_text_value)+" "
					label.add_theme_font_size_override("font_size", small_font_size)
					use_x_velocity = true
				FlashTextType.NoAmmo:
					label.modulate = no_ammo_color
					label.text = " No Ammo "
					label.add_theme_font_size_override("font_size", small_font_size)
					use_x_velocity = false
				FlashTextType.NoTarget:
					label.modulate = no_ammo_color
					label.text = " No Target "
					label.add_theme_font_size_override("font_size", small_font_size)
					use_x_velocity = false
				FlashTextType.Miss:
					label.modulate = normal_damage_color
					label.text = " Miss "
					label.add_theme_font_size_override("font_size", small_font_size)
				FlashTextType.Evade:
					label.modulate = blocked_damage_color
					label.text = " Evade "
					label.add_theme_font_size_override("font_size", small_font_size)
				FlashTextType.Protect:
					label.modulate = blocked_damage_color
					label.text = " Protect "
					label.add_theme_font_size_override("font_size", small_font_size)
				FlashTextType.Message:
					label.modulate = blocked_damage_color
					label.text = " "+str(flash_text_value)+" "
					label.add_theme_font_size_override("font_size", default_font_size)
			
@export var default_font_size:int
@export var small_font_size:int
@export var normal_damage_color:Color
@export var blocked_damage_color:Color
@export var crit_damage_color:Color
@export var healing_damage_color:Color
@export var dot_damage_color:Color
@export var no_ammo_color:Color

@export var label:Label


var min_time = 0.25
var end_time = 1#0.7
var speed_scale = 0.8
var timer = 0

var velocity = 1.0
var gravity = 1.5
var phyics_scale = 2
var use_x_velocity = true
var x_velocity:float = 0
var max_x_velocity:float = 1.5

func set_vfx_data(new_id:String, data:Dictionary):
	super(new_id, data)
	var text_val = data.get("FlashTextVal", "")
	if not text_val:
		printerr("BaseFlashTextVfxNode.set_vfx_data: Not FlashTextVal provided.")
	else:
		flash_text_value = str(text_val)
		# Pad with spaces because shadow gets cut off by bounds
		label.text = " "+str(flash_text_value)+" "
	if data.has("FlashTextType"):
		flash_text_type = data.get("FlashTextType")
	
	if data.has("FlashTextColor"):
		var color = data.get("FlashTextColor")
		label.self_modulate = color
		

func _on_start():
	if use_x_velocity:
		x_velocity = max_x_velocity * (randf() - 0.5) 
	else:
		x_velocity = 0
		gravity = gravity / 2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	if _state == States.Playing:
		timer += delta * speed_scale
		self.position.y -= velocity
		self.position.x += x_velocity
		velocity -= gravity * delta * phyics_scale
		var fade_out = (float(end_time - (timer - min_time)) / float(end_time - min_time))
		self.modulate.a =fade_out
		if fade_out <= 0:
			self.finish()
