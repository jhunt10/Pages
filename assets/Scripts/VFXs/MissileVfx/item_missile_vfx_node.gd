class_name ItemMissileVfxNode
extends MissileVfxNode

func set_vfx_data(new_id:String, data:Dictionary):
	super(new_id, data)
	var sprite_name = _data.get("SpriteName")
	if sprite_name:
		var sprite_path = _data.get("LoadPath", "NO_LOAD_PATH").path_join(sprite_name)
		if ResourceLoader.exists(sprite_path):
			sprite.texture = load(sprite_path)
			sprite.hframes = _data.get("SpriteSheetWidth", 1)
			sprite.vframes = _data.get("SpriteSheetHight", 1)
		else:
			printerr("BaseSpriteVfxNode.set_vfx_data: Failed to find file '%s'." % [sprite_path])
			_bad_sprite = true
	else:
		printerr("BaseSpriteVfxNode.set_vfx_data: VFXData '%s' has no sprite." % [_data.get("VfxKey")])
		_bad_sprite = true
	
	if _bad_sprite:
		sprite.texture = load(NO_SPRITE_PATH)
	else:
		sprite.visible = false
	
	if _data.get("MatchSourceDir", false):
		var dir = _data.get("Direction", 0)
		if dir == 1: sprite.rotation_degrees = 90
		if dir == 2: sprite.rotation_degrees = 180
		if dir == 3: sprite.rotation_degrees = 270
