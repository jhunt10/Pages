class_name ActorSpriteHolder

var _actor:BaseActor
var _cached_body_sprite:Texture2D
var _cached_main_hand_over_sprite:Texture2D
var _cached_off_hand_over_sprite:Texture2D
var _cached_two_hand_over_sprite:Texture2D
var _cached_portrait:Texture2D

func _init(actor:BaseActor) -> void:
	self._actor = actor
	actor.equipment_changed.connect(_build_sprite_sheet)

func get_portrait_sprite()->Texture2D:
	if !_cached_portrait:
		_build_sprite_sheet()
	return _cached_portrait

func get_corpse_sprite()->Texture2D:
	if _actor.get_load_val("CorpseSprite"):
		return SpriteCache.get_sprite(_actor.get_load_path().path_join(_actor.get_load_val("CorpseSprite")))
	return SpriteCache._get_no_sprite()


func get_body_sprite()->Texture2D:
	if _cached_body_sprite == null:
		_build_sprite_sheet()
	return _cached_body_sprite

func get_main_hand_sprite()->Texture2D:
	if _cached_main_hand_over_sprite == null:
		_build_sprite_sheet()
	return _cached_main_hand_over_sprite

func get_off_hand_sprite()->Texture2D:
	if _cached_off_hand_over_sprite == null:
		_build_sprite_sheet()
	return _cached_off_hand_over_sprite

func get_two_hand_sprite()->Texture2D:
	if _cached_two_hand_over_sprite == null:
		_build_sprite_sheet()
	return _cached_two_hand_over_sprite

func _build_sprite_sheet():
	var first_cache = (_cached_body_sprite == null)
	var sprite_sheet_file = _actor.get_load_val("SpriteSheet", null)
	if !sprite_sheet_file:
		_cached_body_sprite = _actor.get_large_icon()
		_cached_portrait = _actor.get_large_icon()
		return
	
	#var old_version = sprite_sheet_file.ends_with(".png")
	#var sprite_path = ''
	#if old_version:
	var sprite_path =_actor.get_load_path().path_join(sprite_sheet_file).trim_suffix(".png")
	var body_texture:Texture2D = SpriteCache.get_sprite(sprite_path+".png", true)
	if !body_texture:
		printerr("Failed to find boday texture: %s" % [sprite_path])
		_cached_body_sprite = SpriteCache._get_no_sprite()
		_cached_portrait = SpriteCache._get_no_sprite()
		return
	var main_hand_texture:Texture2D = SpriteCache.get_sprite(sprite_path+"_MainHand.png", true)
	var off_hand_texture:Texture2D = SpriteCache.get_sprite(sprite_path+"_OffHand.png", true)
	var two_hand_texture:Texture2D = SpriteCache.get_sprite(sprite_path+"_TwoHand.png", true)
	
	var body_image = body_texture.get_image()
	var main_hand_image = null
	if main_hand_texture:
		main_hand_image = main_hand_texture.get_image()
	var off_hand_image = null
	if off_hand_texture:
		off_hand_image = off_hand_texture.get_image()
	var two_hand_image = null
	if two_hand_texture:
		two_hand_image = two_hand_texture.get_image()
	
	var sheet_size = body_image.get_size()
	var sheet_rect = Rect2i(0, 0, sheet_size.x, sheet_size.y)
	
	# Maerge Equipment Images
	for item in _get_draw_ordered_equipment():
		# Skip weapons
		if item is BaseWeaponEquipment:
			continue
		var equip_sprite_path = item.get_sprite_sheet_file_path()
		if !equip_sprite_path:
			continue
		equip_sprite_path = equip_sprite_path.trim_suffix(".png")
		var equip_body_texture = SpriteCache.get_sprite(equip_sprite_path + ".png", true)
		if equip_body_texture:
			var equip_image = equip_body_texture.get_image()
			body_image.blend_rect(equip_image, sheet_rect, Vector2i.ZERO)
		
		if main_hand_image:
			var equip_hand_texture = SpriteCache.get_sprite(equip_sprite_path + "_MainHand.png", true)
			if equip_hand_texture:
				var equip_image = equip_hand_texture.get_image()
				main_hand_image.blend_rect(equip_image, sheet_rect, Vector2i.ZERO)
		
		if off_hand_image:
			var equip_off_hand_texture = SpriteCache.get_sprite(equip_sprite_path + "_OffHand.png", true)
			if equip_off_hand_texture:
				var equip_image = equip_off_hand_texture.get_image()
				off_hand_image.blend_rect(equip_image, sheet_rect, Vector2i.ZERO)
		
		if two_hand_image:
			var equip_two_hand_texture = SpriteCache.get_sprite(equip_sprite_path + "_TwoHand.png", true)
			if equip_two_hand_texture:
				var equip_image = equip_two_hand_texture.get_image()
				two_hand_image.blend_rect(equip_image, sheet_rect, Vector2i.ZERO)
	
	_cached_body_sprite = ImageTexture.create_from_image(body_image)
	if main_hand_image:
		_cached_main_hand_over_sprite = ImageTexture.create_from_image(main_hand_image)
	if off_hand_image:
		_cached_off_hand_over_sprite = ImageTexture.create_from_image(off_hand_image)
	if two_hand_image:
		_cached_two_hand_over_sprite = ImageTexture.create_from_image(two_hand_image)
	
	var port_rect = _actor.get_load_val("PortraitRect", null)
	if !port_rect:
		_cached_portrait = _actor.get_small_icon()
	else:
		var rect = Rect2i(port_rect[0], port_rect[1], port_rect[2], port_rect[3])
		var port_image = body_image.get_region(rect)
		_cached_portrait = ImageTexture.create_from_image(port_image)
	if not first_cache:
		_actor.sprite_changed.emit()

func _get_draw_ordered_equipment()->Array:
	var out_list = []
	var all_equipment = _actor.equipment.list_equipment()
	var draw_order = ["Feet", "Body", "Head", "OffHand", "MainHand" ]
	for slot in draw_order:
		for equip:BaseEquipmentItem in all_equipment:
			if equip.get_equipment_slot_type() == slot:
				if equip.has_spite_sheet():
					out_list.append(equip)
	for page:BasePageItem in _actor.pages.list_items():
		if page.has_spite_sheet():
			out_list.append(page)
	return out_list

func get_black_and_white_portrait()->Texture2D:
	var port:Texture2D = get_portrait_sprite()
	var org_image = port.get_image()
	var new_image = Image.create(org_image.get_width(), org_image.get_height(), false, org_image.get_format())
	new_image.decompress()
	for y in org_image.get_size().y:
		for x in org_image.get_size().x:
			var color = org_image.get_pixel(x, y)
			var max_val = max(color.r, color.b, color.g)
			var min_val = min(color.r, color.b, color.g)
			var value = (color.r + color.b + color.g) / 3.0
			var new_color = Color(value, value, value, color.a)
			new_image.set_pixel(x, y, new_color)
	var new_port = ImageTexture.create_from_image(new_image)
	return new_port
