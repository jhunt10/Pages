class_name BaseStatMod

var effect_id:String
var stat_name:String
var mod_type:ModTypes
var value

enum ModTypes {
	Fixed, # Add to stat 	| x = x + val
	Scale, # Multiply stat 	| x = x * val 
}

func _init(effect_id:String, stat_name:String, data:Dictionary) -> void:
	self.effect_id = effect_id
	self.stat_name = stat_name
	var type = ModTypes.get(data["ModType"])
	if type:
		self.mod_type = type
	else:
		printerr("Unknown Stat Mod Type: %s" % [data["ModType"]])
		self.mod_type = ModTypes.Fixed
	self.value = data["Value"]
