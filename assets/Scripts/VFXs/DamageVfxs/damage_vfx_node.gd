class_name DamageVfxNode
extends BaseSpriteVfxNode

var _use_flash_text:bool = false
var _flash_text_shown:bool = false
var _flash_text_value:String
var _flash_text_color:Color

func _on_start():
	super()
	_use_flash_text = _data.has("DamageNumber")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	if _use_flash_text and animation_half_way and not _flash_text_shown:
		show_flash_text()

func show_flash_text():
	var damage_number = _data.get("DamageNumber", 0)
	var damage_color = _data.get("DamageColor", Color.WHITE)
	var damage_text_type = _data.get("DamageTextType", FlashTextController.FlashTextType.Normal_Dmg)
	var damage_string = str(damage_number)
	vfx_holder.flash_text_controller.add_flash_text(damage_string, damage_text_type)
	_flash_text_shown = true
