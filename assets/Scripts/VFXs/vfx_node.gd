class_name VfxNode
extends Node2D

const NO_SPRITE_PATH = "res://assets/Sprites/BadSprite.png"

@export var sprite:Sprite2D
@export var animation:AnimationPlayer
@export var animation_half_way:bool
var _data:VfxData
var _bad_sprite = false

var _readyed = false
var _delayed_start = false
var _has_animation = false

var _flash_text_shown:bool = false
var _flash_text_value:String
var _flash_text_color:Color

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_readyed = true
	if _delayed_start:
		start_vfx()
	pass # Replace with function body.

func start_vfx():
	if !_readyed:
		_delayed_start = true
		return
	sprite.position = _data.fixed_offset
	if _data.random_offset_range != Vector2.ZERO:
		var sprite_size = sprite.get_rect().size
		var offset_x = randf_range(-_data.random_offset_range.x, _data.random_offset_range.x) * sprite_size.x
		var offset_y = randf_range(-_data.random_offset_range.y, _data.random_offset_range.y) * sprite_size.y
		sprite.position += Vector2(offset_x, offset_y)
	if _data.animation_name != '':
		_has_animation = true
		animation.play(_data.animation_name)
		animation.speed_scale = _data.animation_speed
	sprite.visible = true
	animation_half_way = false
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _has_animation and !animation.is_playing():
		self.queue_free()
	if _flash_text_value and animation_half_way and not _flash_text_shown:
			CombatRootControl.Instance.create_flash_text(self.get_parent(), _flash_text_value, _flash_text_color)
			_flash_text_shown = true

func set_vfx_data(data:VfxData, extra_data:Dictionary):
	_data = data
	if _data.sprite_name != '':
		var sprite_path = _data.load_path.path_join(data.sprite_name)
		if ResourceLoader.exists(sprite_path):
			sprite.texture = load(sprite_path)
			sprite.hframes = _data.sprite_sheet_width
			sprite.vframes = _data.sprite_sheet_hight
			sprite.scale = Vector2(_data.scale,_data.scale)
		else:
			printerr("VfxNode.set_vfx_data: Failed to find file '%s'." % [sprite_path])
			_bad_sprite = true
	else:
		printerr("VfxNode.set_vfx_data: VFXData '%s' has no sprite." % [_data.VFXKey])
		_bad_sprite = true
	
	if _bad_sprite:
		sprite.texture = load(NO_SPRITE_PATH)
	else:
		sprite.visible = false

func add_flash_text(text:String, color:Color):
	_flash_text_value = text
	_flash_text_color = color
	
