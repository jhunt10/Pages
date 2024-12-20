class_name BaseLoadObject

var _id:String
var _def_load_path:String
var _key:String
var _def:Dictionary
var _data:Dictionary
var is_deleted:bool = false

var details:ObjectDetailsData

func _init(key:String, def_load_path:String, def:Dictionary, id:String='', data:Dictionary={}) -> void:
	if is_static():
		self._id = key
	elif id != '':
		self._id = id
	else:
		self._id = key + str(ResourceUID.create_id())
	self._key = key
	self._def_load_path = def_load_path
	self._def = def
	self._data = data
	details = ObjectDetailsData.new(self._def_load_path, self._def.get("Details", {}))

func post_creation():
	pass

## Is this class static. Static objects don't use _data and are referenced only by _key
func is_static():
	return false

func save_me()->bool:
	return false

func save_data()->Dictionary:
	if !_data.keys().has("ObjectKey"):
		_data['ObjectKey'] = self._key
	return _data

func get_load_path()->String:
	return _def_load_path

# TODO: Better name and description
## Returns the value of given key if found in _data or _def in that order
func get_load_val(key:String, default=null):
	return _data.get(key, _def.get(key, default))

func on_delete():
	is_deleted = true
