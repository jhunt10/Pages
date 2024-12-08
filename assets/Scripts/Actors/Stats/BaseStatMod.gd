class_name BaseStatMod

var source_id:String
var stat_name:String
var display_name:String
var mod_type:ModTypes
var value

enum ModTypes {
	Add, # Add to stat 		| x = x + val
	Scale, # Multiply stat 		| x = x * val 
	Set, # Set the stat 	| x = val
}

static func create_from_data(source_id:String, data:Dictionary) -> BaseStatMod:
	var type_key:String = data["ModType"]
	var type = ModTypes.get(type_key)
	var set_mode_type
	if type != null:
		set_mode_type = type
	else:
		printerr("Unknown Stat Mod Type: %s" % [type_key])
		set_mode_type = ModTypes.Add
	return BaseStatMod.new(source_id, data['StatName'], data['DisplayName'], set_mode_type, data["Value"])

func _init(source_id:String, stat_name:String, display_name:String, mod_type:ModTypes, value):
	self.source_id = source_id
	self.stat_name = stat_name
	self.display_name = display_name
	self.mod_type = mod_type
	self.value = value
