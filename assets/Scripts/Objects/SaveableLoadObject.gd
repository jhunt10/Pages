## A Saveable Object is an object that is unique in each instance. 
## It has a def which defines it's base properties and data that must be preserved.
class_name SaveableLoadObject
extends  BaseLoadObject

func _init(key:String, load_path:String, def:Dictionary, data:Dictionary) -> void:
	super(key, load_path, def, data)
