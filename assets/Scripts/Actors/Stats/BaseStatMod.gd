class_name BaseStatMod

var source_id:String
var stat_name:String
var display_name:String
var mod_type:ModTypes
var value
var dep_stat_name:String

 # For AttackMods
var source_faction:int
var condition_data:Dictionary = {}

enum ModTypes {
	Add, # Add to stat 		| x = x + val
	Scale, # Multiply stat 		| x = x * val 
	Set, # Set the stat 	| x = val
	
	AddStat, # Add other_stat to stat | x = x + [Stat]
	ScaleStat
}

static func create_from_data(source_id:String, data:Dictionary) -> BaseStatMod:
	var type_key:String = data["ModType"]
	var type = ModTypes.get(type_key)
	var set_mode_type
	if type != null:
		set_mode_type = type
	else:
		printerr("Stat Mod: '%s' Unknown Stat Mod Type: %s" % [data.get("DisplayName", "NO NAME"), type_key])
		set_mode_type = ModTypes.Add
	if set_mode_type == ModTypes.AddStat:
		if not data.has("DepStatName"):
			printerr("Stat Mod: '%s' set to AddStat but is missing 'DepStatName'." % [data.get("DisplayName", "NO NAME")])
			set_mode_type = ModTypes.Add
	var stat_mod = BaseStatMod.new(
		source_id, 
		data['StatName'], 
		data['DisplayName'], 
		set_mode_type, 
		data["Value"], 
		data.get("DepStatName", null),
	)
	if data.has("SourceActorFaction"):
		stat_mod.source_faction = data['SourceActorFaction']
	if data.has("Conditions"):
		stat_mod.condition_data = data['Conditions']
	return stat_mod

func get_as_data()->Dictionary:
	return {
		"SourceActorId": "ActorId",
		"SourceActorFaction": 0,
		"DisplayName": self.display_name,
		"ModType": ModTypes.keys()[self.mod_type],
		"StatName": self.stat_name,
		"Value": self.value
	}

func _init(source_id:String, stat_name:String, display_name:String, mod_type:ModTypes, value, dep_stat=null):
	# TODO: CanStack Id Logic for all Stat Mods (like I just did for Damage and Attack Mods)
	self.source_id = source_id
	self.stat_name = stat_name
	self.display_name = display_name
	self.mod_type = mod_type
	if dep_stat:
		self.dep_stat_name = dep_stat
	self.value = value
