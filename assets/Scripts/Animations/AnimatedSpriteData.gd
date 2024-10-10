class_name AnimatedSpriteData

const NO_SPRITE_PATH = "res://assets/Sprites/BadSprite.png"

var _load_path:String = ''
var _data:Dictionary = {}
var _defaults:Dictionary = {
	"TileSheetWidth": 1,
	"TileSheetHight": 1,
	"AnimationSpeed": 1.0,
}

var _cached_sprite:Texture2D = null
var _bad_sprite = false

func _init(data:Dictionary, load_path:String = '', defaults:Dictionary={}) -> void:
	_data = data
	for key in defaults.keys():
		_defaults[key] = defaults[key]
	
	if load_path != '':
		_load_path = load_path
	elif data.has("LoadPath"):
		_load_path = data['LoadPath']
	elif defaults.has("LoadPath"):
		_load_path = defaults['LoadPath']
	else:
		printerr("No LoadPath given to AnimatedSprite: " + JSON.stringify(data))
		return
		
	var test_sprite = get_sprite()

func get_sprite_name()->String:
	return _data.get("SpriteName", _defaults.get("SpriteName", NO_SPRITE_PATH.get_file()))

func get_sprite_path()->String:
	if _load_path == '':
		_bad_sprite = true
		return NO_SPRITE_PATH
	return _load_path.path_join(get_sprite_name())

func get_animation_name()->String:
	if _bad_sprite: return ""
	return _data.get("AnimationName", _defaults.get("AnimationName", ""))
	
func get_sprite_sheet_width()->int:
	if _bad_sprite: return 1
	return _data.get("TileSheetWidth", _defaults.get("TileSheetWidth", 1))

func get_sprite_sheet_hight()->int:
	if _bad_sprite: return 1
	return _data.get("TileSheetHight", _defaults.get("TileSheetHight", 1))

func get_animation_speed()->float:
	if _bad_sprite: return 1.0
	return _data.get("AnimationSpeed", _defaults.get("AnimationSpeed", 1.0))

func get_sprite()->Texture2D:
	if not _cached_sprite:
		_cached_sprite = load(get_sprite_path())
		if not _cached_sprite:
			_bad_sprite = true
			_cached_sprite = load(NO_SPRITE_PATH)
			printerr('Failed to load sprite: ' + get_sprite_path())
	return _cached_sprite

func set_sprite_and_animation(sprite:Sprite2D, animation:AnimationPlayer):
	sprite.texture = get_sprite()
	sprite.hframes = get_sprite_sheet_width()
	sprite.vframes = get_sprite_sheet_hight()
	var animation_name = get_animation_name()
	if animation_name != "":
		animation.speed_scale = get_animation_speed()
		animation.play(animation_name)


func save_data()->Dictionary:
	var dict = {}
	dict["SpriteName"] = get_sprite_name()
	dict["AnimationName"] = get_animation_name()
	dict["AnimationSpeed"] = get_animation_speed()
	dict["TileSheetWidth"] = get_sprite_sheet_width()
	dict["TileSheetHight"] = get_sprite_sheet_hight()
	return dict
