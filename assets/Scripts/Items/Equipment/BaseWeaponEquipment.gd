class_name BaseWeaponEquipment
extends BaseEquipmentItem

enum WeaponClasses {Light, Medium, Heavy}

var target_parmas:TargetParameters

var _loaded_sprites:bool = false
var _main_hand_sprite:Texture2D
var _off_hand_sprite:Texture2D
var _two_hand_sprite:Texture2D

func _init(key:String, def_load_path:String, def:Dictionary, id:String='', data:Dictionary={}) -> void:
	super(key, def_load_path, def, id, data)
	target_parmas = TargetParameters.new("Weapon", get_load_val("TargetParams", {}))

func get_equipment_slot_type()->String:
	return "Weapon"

func get_item_type()->ItemTypes:
	return ItemTypes.Weapon
	
func get_item_tags()->Array:
	var tags = super()
	if !tags.has("Weapon"):
		tags.append("Weapon")
	if !tags.has("MainHand"):
		tags.append("MainHand")
	return tags

func get_weapon_class()->WeaponClasses:
	var val = get_load_val("WeaponClass", '')
	if WeaponClasses.keys().has(val):
		return WeaponClasses.get(val)
	return WeaponClasses.Medium

func get_damage_data()->Dictionary:
	return get_load_val("DamageData", {})

func get_ammo_data()->Dictionary:
	return get_load_val("AmmoData", {})

func get_misile_data()->Dictionary:
	return get_load_val("MissileData", {})

func get_main_hand_sprite()->Texture2D:
	if !_loaded_sprites:
		_build_sprite_sheets()
	return _main_hand_sprite

func get_two_hand_sprite()->Texture2D:
	if !_loaded_sprites:
		_build_sprite_sheets()
	return _two_hand_sprite

func get_off_hand_sprite()->Texture2D:
	if !_loaded_sprites:
		_build_sprite_sheets()
	return _off_hand_sprite

func get_sprite_sheet()->Texture2D:
	if !_loaded_sprites:
		_build_sprite_sheets()
	if is_equipped_to_actor():
		var actor:BaseActor = ActorLibrary.get_actor(get_equipt_to_actor_id())
		if actor.equipment.is_two_handing():
			return _two_hand_sprite
		var primary = actor.equipment.get_primary_weapon()
		if self.Id != primary.Id:
			return _off_hand_sprite
	return _main_hand_sprite

func get_equipt_sprite()->Texture2D:
	var sprite_file = get_load_val("WeaponSprite", null)
	if not sprite_file:
		return null
	var sprite_path = _def_load_path.path_join(sprite_file)
	return load(sprite_path)
	
func get_overhand_sprite()->Texture2D:
	var sprite_file = get_load_val("OverHandSprite", null)
	if not sprite_file:
		return null
	var sprite_path = _def_load_path.path_join(sprite_file)
	return load(sprite_path)
	

func _build_sprite_sheets():
	var sprite_sheet_file = get_load_val("SpriteSheet", null)
	if !sprite_sheet_file:
		return
	var sprite_path = _def_load_path.path_join(sprite_sheet_file)
	var actor_sprite:Texture2D = load(sprite_path)
	var sheet_image = actor_sprite.get_image()
	var sheet_size = sheet_image.get_size()
	var sub_sheet_rect_1 = Rect2i(0, 0, sheet_size.x/2, sheet_size.y)
	var sub_sheet_rect_2 = Rect2i(sheet_size.x/2, 0, sheet_size.x/2, sheet_size.y)
	if get_weapon_class() == WeaponClasses.Heavy:
		_main_hand_sprite = ImageTexture.create_from_image(sheet_image.get_region(sub_sheet_rect_1))
		_two_hand_sprite = ImageTexture.create_from_image(sheet_image.get_region(sub_sheet_rect_2))
	if get_weapon_class() == WeaponClasses.Medium:
		_main_hand_sprite = ImageTexture.create_from_image(sheet_image.get_region(sub_sheet_rect_1))
		_two_hand_sprite = ImageTexture.create_from_image(sheet_image.get_region(sub_sheet_rect_2))
	if get_weapon_class() == WeaponClasses.Light:
		_main_hand_sprite = ImageTexture.create_from_image(sheet_image.get_region(sub_sheet_rect_1))
		_off_hand_sprite = ImageTexture.create_from_image(sheet_image.get_region(sub_sheet_rect_2))
	_loaded_sprites = true
