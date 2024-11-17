class_name BaseActor
extends BaseLoadObject

# These signals are emited by ActionQueController
## Emitted only when this Actor starts a turn (not emitted on gap turns)
signal turn_starting
## Emitted only when this Actor ends a turn (not emitted on gap turns)
signal turn_ended
# This is just here because I don't want all the Holders to have to connect dirrectly to ActionQueController
signal round_starting
signal round_ended

signal equipment_changed
signal bag_items_changed
signal page_list_changed
signal action_que_changed

# Actor holds no references to the current map state so this method is called by MapState.set_actor_pos()
signal on_move(old_pos:MapPos, new_pos:MapPos, move_type:String, moved_by:BaseActor)
signal on_death()
signal sprite_changed()

var Que:ActionQue
var node:ActorNode
var stats:StatHolder
var effects:EffectHolder
var items:ItemHolder
var details:ObjectDetailsData
var equipment:EquipmentHolder
var pages:PageHolder

var Id : String:
	get: return _id
var ActorKey : String:
	get: return _key
func get_tagable_id(): return Id
func get_tags(): return Tags

var FactionIndex : int

var LoadPath:String:
	get: return _def_load_path
var DisplayName:String:
	get: return _data.get("DisplayName", details.display_name)
	set(val): _data["DisplayName"] = val
var SnippetDesc:String:
	get: return details.snippet
var Description:String:
	get: return details.description
var Tags:Array = []

var spawn_map_layer

var _cached_body_sprite:Texture2D
var _cached_main_hand_over_sprite:Texture2D
var _cached_off_hand_over_sprite:Texture2D
var _cached_two_hand_over_sprite:Texture2D
var _cached_portrait:Texture2D

var _allow_auto_que:bool = false

var is_dead:bool = false

func _init(key:String, load_path:String, def:Dictionary, id:String, data:Dictionary) -> void:
	super(key, load_path, def, id, data)
	spawn_map_layer = _def.get('SpawnOnMapLayer', MapStateData.DEFAULT_ACTOR_LAYER)
	
	var auto_que_list = _def.get("AutoQue", [])
	_allow_auto_que = auto_que_list.size() > 0
	
	var stat_data = _def["Stats"]
	stats = StatHolder.new(self, stat_data)
	effects = EffectHolder.new(self)
	details = ObjectDetailsData.new(_def_load_path, _def.get("Details", {}))
	equipment = EquipmentHolder.new(self)
	items = ItemHolder.new(self)
	Que = ActionQue.new(self)
	pages = PageHolder.new(self)
	
	self.equipment_changed.connect(_build_sprite_sheet)
	

func save_data()->Dictionary:
	var data = super()
	data['Pages'] = pages.get_pages_per_page_tags()
	data['BagItems'] = items.get_items_per_item_tags()
	return data

func on_combat_start():
	effects.on_combat_start()

func set_pos(old_pos:MapPos, new_pos:MapPos, move_type:String, moved_by:BaseActor):
	on_move.emit(old_pos, new_pos, move_type, moved_by)
	node.set_display_pos(new_pos)

func on_turn_failed():
	node.cancel_current_animation()

func die():
	is_dead = true
	on_death.emit()
	node.set_corpse_sprite()
	
func get_portrait_sprite()->Texture2D:
	if !_cached_portrait:
		_build_sprite_sheet()
	return _cached_portrait

func get_coprse_texture()->Texture2D:
	if _def.has("CorpseSprite"):
		return SpriteCache.get_sprite(_def_load_path + "/" +_def['CorpseSprite'])
	return SpriteCache._get_no_sprite()

func auto_build_que(current_turn:int):
	if !_allow_auto_que:
		return
	var auto_que_list = get_load_val("AutoQue", null)
	if Que:
		for action_key in auto_que_list:
			var action = ActionLibrary.get_action(action_key)
			print("AutoQue: " + action.ActionKey)
			if action:
				Que.que_action(action)
			
func get_action_list()->Array:
	return pages.list_action_keys()

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
	var sprite_sheet_file = get_load_val("SpriteSheet", null)
	if !sprite_sheet_file:
		_cached_body_sprite = SpriteCache.get_sprite(details.large_icon_path)
		_cached_portrait = SpriteCache.get_sprite(details.large_icon_path)
		return
	
	var sprite_path = _def_load_path.path_join(sprite_sheet_file).trim_suffix(".png")
	var body_texture:Texture2D = SpriteCache.get_sprite(sprite_path+".png")
	var main_hand_texture:Texture2D = SpriteCache.get_sprite(sprite_path+"_MainHand.png")
	var off_hand_texture:Texture2D = SpriteCache.get_sprite(sprite_path+"_OffHand.png")
	var two_hand_texture:Texture2D = SpriteCache.get_sprite(sprite_path+"_TwoHand.png")
	
	var body_image = body_texture.get_image()
	var main_hand_image = main_hand_texture.get_image()
	var off_hand_image = off_hand_texture.get_image()
	var two_hand_image = two_hand_texture.get_image()
	
	var sheet_size = body_image.get_size()
	var sheet_rect = Rect2i(0, 0, sheet_size.x, sheet_size.y)
	
	# Maerge Equipment Images
	for item:BaseEquipmentItem in _get_draw_ordered_equipment():
		# Skip weapons
		if item.get_equipment_slot_type() == "Weapon":
			continue
		var equip_sprite_path = item.get_sprite_sheet_file_path()
		if !equip_sprite_path:
			continue
		equip_sprite_path = equip_sprite_path.trim_suffix(".png")
		var equip_body_texture = SpriteCache.get_sprite(equip_sprite_path + ".png", true)
		if equip_body_texture:
			var equip_image = equip_body_texture.get_image()
			body_image.blend_rect(equip_image, sheet_rect, Vector2i.ZERO)
		
		var equip_hand_texture = SpriteCache.get_sprite(equip_sprite_path + "_MainHand.png", true)
		if equip_hand_texture:
			var equip_image = equip_hand_texture.get_image()
			main_hand_image.blend_rect(equip_image, sheet_rect, Vector2i.ZERO)
		
		var equip_off_hand_texture = SpriteCache.get_sprite(equip_sprite_path + "_OffHand.png", true)
		if equip_off_hand_texture:
			var equip_image = equip_off_hand_texture.get_image()
			off_hand_image.blend_rect(equip_image, sheet_rect, Vector2i.ZERO)
		
		var equip_two_hand_texture = SpriteCache.get_sprite(equip_sprite_path + "_TwoHand.png", true)
		if equip_two_hand_texture:
			var equip_image = equip_two_hand_texture.get_image()
			two_hand_image.blend_rect(equip_image, sheet_rect, Vector2i.ZERO)
	
	_cached_body_sprite = ImageTexture.create_from_image(body_image)
	_cached_main_hand_over_sprite = ImageTexture.create_from_image(main_hand_image)
	_cached_off_hand_over_sprite = ImageTexture.create_from_image(off_hand_image)
	_cached_two_hand_over_sprite = ImageTexture.create_from_image(two_hand_image)
	
	var port_rect = get_load_val("PortraitRect", null)
	if !port_rect:
		_cached_portrait = ImageTexture.create_from_image(body_image)
	else:
		var rect = Rect2i(port_rect[0], port_rect[1], port_rect[2], port_rect[3])
		var port_image = body_image.get_region(rect)
		_cached_portrait = ImageTexture.create_from_image(port_image)
	if not first_cache:
		sprite_changed.emit()

func _get_draw_ordered_equipment()->Array:
	var out_list = []
	var all_equipment = equipment.list_equipment()
	var draw_order = ["Feet", "Body", "Head", "OffHand", "MainHand" ]
	for slot in draw_order:
		for equip:BaseEquipmentItem in all_equipment:
			if equip.get_equipment_slot_type() == slot:
				if equip.get_load_val("SpriteSheet", null):
					out_list.append(equip)
	return out_list
