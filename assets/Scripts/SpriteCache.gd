class_name SpriteCache

const NO_SPRITE_PATH = "res://assets/Sprites/BadSprite.png"

static var _cached_sprites:Dictionary = {}
static var _cached_overlay_sprites:Dictionary = {}

static func get_sprite(path:String, nullable:bool=false)->Texture2D:
	if not _cached_sprites.keys().has(path):
		if not ResourceLoader.exists(path):
			if nullable:
				return null
			else:
				printerr("SpriteCache.get_sprite: No file found: '%s'." % [path])
				return _get_no_sprite()
		var sprite:Texture2D = load(path)
		if !sprite:
			if nullable:
				return null
			else:
				printerr("SpriteCache.get_sprite: Failed to load file as Texture2D: '%s'." % [path])
				return _get_no_sprite()
		_cached_sprites[path] = sprite
	return _cached_sprites[path]
	
static func _get_no_sprite()->Texture2D:
	if not _cached_sprites.keys().has(NO_SPRITE_PATH):
		var sprite:Texture2D = load(NO_SPRITE_PATH)
		if !sprite:
			printerr("SpriteCache._get_no_sprite: Failed to NO_SPRITE.")
			return null
		_cached_sprites[NO_SPRITE_PATH] = sprite
	return _cached_sprites[NO_SPRITE_PATH]

static func get_item_overlay_sprite(item, overlay_sprite_path)->Texture2D:
	if item is String:
		item = ItemLibrary.get_item(item)
	if !item or not item is BaseItem:
		return _get_no_sprite()
	
	var overlay_key = item.ItemKey + overlay_sprite_path
	if not _cached_overlay_sprites.keys().has(overlay_key):
		var base_sprite = (item as BaseItem).get_large_icon()
		var overlay_sprite = get_sprite(overlay_sprite_path, true)
		if !overlay_sprite:
			return _get_no_sprite()
		
		var base_image = base_sprite.get_image()
		var image_size = base_image.get_size()
		var image_rect = Rect2i(0, 0, image_size.x, image_size.y)
		
		var overlay_image = overlay_sprite.get_image()
		base_image.blend_rect(overlay_image, image_rect, Vector2i.ZERO)
		var new_sprite = ImageTexture.create_from_image(base_image)
		_cached_overlay_sprites[overlay_key] = new_sprite
	
	return _cached_overlay_sprites[overlay_key]
	
