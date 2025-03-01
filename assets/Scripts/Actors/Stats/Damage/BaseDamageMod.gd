class_name BaseDamageMod

var effect_id:String
var stat_name:String
var display_name:String
var mod_type:ModTypes
var on_deal_damage:bool
var on_take_damage:bool
## Damage Types to apply this mod to. If left empty, will apply to all non-excluded types
var include_damage_types:Array
## Damage Types that this mod will not be applied to. A value that also apears in include_damage_types will still be excluded. 
var exclude_damage_types:Array
## Tags to apply this mod to. If left empty, will apply to all non-excluded types
var include_tags:Array
## Tags that this mod will not be applied to. A value that also apears in include_tags will still be excluded. 
var exclude_tags:Array
var value

enum ModTypes {
	Add, # Add to stat 		| x = x + val
	Scale, # Multiply stat 		| x = x * val 
	#Replc, # Replaces the stat 	| x = val
}

func _init(source_effect_id:String, data:Dictionary) -> void:
	self.effect_id = source_effect_id
	self.stat_name = data['StatName']
	self.display_name = data['DisplayName']
	var type_key:String = data["ModType"]
	var type = ModTypes.get(type_key)
	if type != null:
		self.mod_type = type
	else:
		printerr("Unknown Stat Mod Type: %s" % [type_key])
		self.mod_type = ModTypes.Add
	self.on_deal_damage = data.get("OnDealDamage", false)
	self.on_take_damage = data.get("OnTakeDamage", false)
	self.value = data["Value"]

func is_valid_in_event(taking_damage:bool, attack_tags:Array, defense_tags:Array, _event:DamageEvent):
	if taking_damage:
		if not on_take_damage: return false
	else:
		if not on_deal_damage: return false
	
	# False if any tags are excluded
	if exclude_tags.any(attack_tags.has):
		return false
	if SourceTagChain.tags_include_any_in_array(exclude_tags, defense_tags):
		return false
	
	if include_tags.size() > 0:
		var found_included = false
		if SourceTagChain.tags_include_any_in_array(include_tags, attack_tags):
			found_included = true
		if SourceTagChain.tags_include_any_in_array(include_tags, defense_tags):
			found_included = true
		if not found_included:
			return false
	return true

func apply_mod(current_value:float, _event:DamageEvent)->float:
	if mod_type == ModTypes.Add:
		return current_value + self.value
	if mod_type == ModTypes.Scale:
		return current_value * self.value
	printerr("BaseDamageMod.apply_mod: Unknown Mod Type '%s'." % [mod_type])
	return current_value
