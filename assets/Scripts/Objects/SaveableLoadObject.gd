### A Saveable Object is an object that is unique in each instance. 
### It has a def which defines it's base properties and data that must be preserved.
#class_name SaveableLoadObject
#extends  BaseLoadObject
#
#var _save_data:Dictionary
#
#func _init(key:String, load_path:String, def:Dictionary, save_data:Dictionary) -> void:
	#self._save_data = save_data
	#super(key, load_path, def)
