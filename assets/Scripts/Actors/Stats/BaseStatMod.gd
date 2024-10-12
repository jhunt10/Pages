class_name BaseStatMod

var effect_id:String
var stat_name:String
var display_name:String
var mod_type:ModTypes
var value

enum ModTypes {
	Add, # Add to stat 		| x = x + val
	Scale, # Multiply stat 		| x = x * val 
	Replc, # Replaces the stat 	| x = val
}

func _init(effect_id:String, data:Dictionary) -> void:
	self.effect_id = effect_id
	self.stat_name = data['StatName']
	self.display_name = data['DisplayName']
	var type_key:String = data["ModType"]
	var type = ModTypes.get(type_key)
	if type != null:
		self.mod_type = type
	else:
		printerr("Unknown Stat Mod Type: %s" % [type_key])
		self.mod_type = ModTypes.Add
	self.value = data["Value"]
