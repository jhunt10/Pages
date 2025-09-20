class_name BaseLoadObject

var _id:String
var _def_load_path:String
var _key:String
var _def:Dictionary
var _data:Dictionary
var is_deleted:bool = false

var object_details:Dictionary:
	get:
		return get_load_val("#ObjDetails", {}, false)

func _init(key:String, def_load_path:String, def:Dictionary, id:String='', data:Dictionary={}) -> void:
	if id != '':
		self._id = id
	else:
		self._id = key +":"+ str(ResourceUID.create_id())
	self._key = key
	self._def_load_path = def_load_path
	self._def = def
	self._data = data

func reload_def(load_path:String, def:Dictionary):
	self._def_load_path = load_path
	self._def = def

####################
## Object Details ##
####################
func get_object_details()->Dictionary:
	var dets = _def.get("#ObjDetails", {})
	if _data.has("#ObjDetails"):
		dets = BaseLoadObjectLibrary._merge_defs(_data.get("#ObjDetails", {}), dets)
	return dets
func get_display_name()->String:
	var dets = get_object_details()
	return dets.get("DisplayName", _id)
func get_description()->String:
	return get_object_details().get("Description", _id)
func get_snippet()->String:
	return get_object_details().get("SnippetDesc", _id)
func get_large_icon()->Texture2D:
	var icon_path = _def_load_path.path_join(get_object_details().get("LargeIcon", ""))
	return SpriteCache.get_sprite(icon_path)
	
func get_small_icon_path()->String:
	var icon_path = _def_load_path.path_join(get_object_details().get("SmallIcon", ""))
	return icon_path
func get_small_icon()->Texture2D:
	var icon_path = _def_load_path.path_join(get_object_details().get("SmallIcon", ""))
	return SpriteCache.get_sprite(icon_path)

func get_weapon_sprite_sheet_path()->String:
	# Base Weapon Sprite path off of Large Icon Path
	var sprite_file = _def_load_path.path_join(get_object_details().get("LargeIcon", ""))
	if sprite_file.contains("_Icon"):
		sprite_file = sprite_file.replace("_Icon", "")
	sprite_file = sprite_file.replace(".png", "_WeaponSprite.png")
	return sprite_file

func get_tags()->Array:
	return object_details.get("Tags", []).duplicate()
func get_taxonomy()->Array:
	return object_details.get("Taxonomy", []).duplicate()
func get_taxonomy_leaf()->String:
	var tax = object_details.get("Taxonomy", [])
	if tax.size() > 0:
		return tax[tax.size()-1]
	return ''

func save_me()->bool:
	return false

func save_data()->Dictionary:
	var data = _data.duplicate()
	data['ObjectKey'] = self._key
	data['Id'] = self._id
	return data

func load_data(data:Dictionary):
	_data = data

func get_load_path()->String:
	return _def_load_path

## Return value from  _data  ->  _def  ->  default
func get_load_val(key:String, default=null, duplicate_dict:bool=true):
	var val = _data.get(key, null)
	if val is Dictionary:
		val = val.duplicate(duplicate_dict)
		if _def.has(key):
			val = BaseLoadObjectLibrary._merge_defs(val, _def.get(key, {}))
	if !val:
		val = _def.get(key, default)
		if val is Dictionary:
			val = val.duplicate(duplicate_dict)
	return val

func on_delete():
	is_deleted = true
