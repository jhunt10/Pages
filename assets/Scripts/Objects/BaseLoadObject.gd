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

## Is this class static. Static objects don't use _data and are referenced only by _key
func is_static():
	return false

func save_me()->bool:
	return false

func save_data()->Dictionary:
	var data = _data.duplicate()
	if !data.keys().has("ObjectKey"):
		data['ObjectKey'] = self._key
	if !data.keys().has("Id"):
		data['Id'] = self._id
	return data

func load_data(data:Dictionary):
	_data = data

func get_load_path()->String:
	return _def_load_path

# TODO: Better name and description
## Returns the value of given key if found in _data or _def in that order
func get_load_val(key:String, default=null):
	var val = _data.get(key, _def.get(key, default))
	if val is Dictionary:
		return val.duplicate(true)
	return val

func on_delete():
	is_deleted = true
