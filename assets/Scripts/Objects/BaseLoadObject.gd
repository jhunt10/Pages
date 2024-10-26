class_name BaseLoadObject

var _load_path:String
var _key:String
var _def:Dictionary
var _data:Dictionary

func _init(key:String, load_path:String, def:Dictionary, data:Dictionary) -> void:
	self._key = key
	self._load_path = load_path
	self._def = def
	self._data = data
