class_name SpriteCache

const NO_SPRITE_PATH = "res://assets/Sprites/BadSprite.png"

static var _cached_sprites:Dictionary = {}

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
