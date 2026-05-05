class_name BaseSpriteVfxNode
extends BaseVfxNode

const NO_SPRITE_PATH = "res://assets/Sprites/BadSprite.png"

@export var sprite:Sprite2D
@export var animation:AnimationPlayer
@export var audio_player:AudioStreamPlayer2D

func set_vfx_data(new_id:String, data:Dictionary):
	super(new_id, data)
	
	# Load Sprite
	var sprite_name = _data.get("SpriteName")
	if sprite_name:
		var sprite_path = _data.get("LoadPath", "NO_LOAD_PATH").path_join(sprite_name)
		if ResourceLoader.exists(sprite_path):
			sprite.texture = load(sprite_path)
			sprite.hframes = _data.get("SpriteSheetWidth", 1)
			sprite.vframes = _data.get("SpriteSheetHight", 1)
		else:
			printerr("BaseSpriteVfxNode.set_vfx_data: Failed to find file '%s'." % [sprite_path])
			sprite.texture = load(NO_SPRITE_PATH)
	
	# Load Audio
	if audio_player:
		var sound_effect = _data.get("SFXFilePath", null)
		if sound_effect:
			audio_player.stream = load(sound_effect)
	
	# Hide sprite until started
	sprite.visible = false
	
	if _data.get("MatchSourceDir", false):
		var dir = _data.get("Direction", 0)
		if dir == 1: sprite.rotation_degrees = 90
		if dir == 2: sprite.rotation_degrees = 180
		if dir == 3: sprite.rotation_degrees = 270

func _on_start():
	# Transform Sprite
	if _data.has("Offset"):
		var offset = _data['Offset']
		sprite.position = Vector2(offset[0], offset[1])
	if _data.has("Rotation"):
		sprite.rotation_degrees = _data['Rotation']
	if _data.has("RandomOffsets"):
		var random_offset_range = _data.get("RandomOffsets", [0,0])
		var sprite_size = sprite.get_rect().size
		var offset_x = randf_range(-random_offset_range[0], random_offset_range[1]) * sprite_size.x
		var offset_y = randf_range(-random_offset_range[0], random_offset_range[1]) * sprite_size.y
		sprite.position += Vector2(offset_x, offset_y)
	if _data.has("RandomRotation"):
		var rot_range = _data.get("RandomRotation")
		self.rotation_degrees = randf_range(rot_range[0], rot_range[1])
	if _data.has("Scale"):
		var scale_data = _data.get("Scale", 1)
		if scale_data is Array:
			sprite.scale = Vector2(scale_data[0], scale_data[1])
		else:
			sprite.scale = Vector2(scale_data, scale_data)
	
	if animation:
		var animation_name = _data.get("AnimationName", "main_animation")
		if animation_name:
			animation.play(animation_name)
			animation.speed_scale = _data.get("AnimationSpeed", 1)
			animation.animation_finished.connect(_on_animation_finish)
	
	if audio_player:
		audio_player.play()
	
	sprite.visible = true


func _on_animation_finish(_animation_name:String):
	if self._state != States.Finished:
		self.finish()
