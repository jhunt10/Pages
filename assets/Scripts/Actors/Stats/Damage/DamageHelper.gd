class_name DamageHelper

const LOGGING = true

const STAT_BALENCE:int = 100

const ElementalDamageTypes:Array = [
	DamageEvent.DamageTypes.Fire,
	DamageEvent.DamageTypes.Cold,
	DamageEvent.DamageTypes.Shock,
	DamageEvent.DamageTypes.Poison
]

const ElementalDamageTypes_Strings:Array = [
	"Fire",
	"Cold",
	"Shock",
	"Poison"
]
const PhysicalDamageTypes:Array = [
	DamageEvent.DamageTypes.Slash,
	DamageEvent.DamageTypes.Blunt,
	DamageEvent.DamageTypes.Pierce,
	DamageEvent.DamageTypes.Crash
]
const PhysicalDamageTypes_Strings:Array = [
	"Slash",
	"Blunt",
	"Pierce",
	"Crash"
]

static func get_damage_color(damage_type, as_text = false):
	if damage_type is String:
		damage_type = DamageEvent.DamageTypes.get(damage_type.trim_suffix(" Damage"))
	var color_text = "000000"
	match damage_type:
		DamageEvent.DamageTypes.Slash: color_text = "8c4f4f"
		DamageEvent.DamageTypes.Blunt: color_text = "597882"
		DamageEvent.DamageTypes.Pierce: color_text = "b4b991"
		DamageEvent.DamageTypes.Crash: color_text = "377A59"
		DamageEvent.DamageTypes.Fire: color_text = "cb0000"
		DamageEvent.DamageTypes.Cold: color_text = "65c1ef"
		DamageEvent.DamageTypes.Shock: color_text = "f2da00"
		DamageEvent.DamageTypes.Poison: color_text = "00a355"
		DamageEvent.DamageTypes.Light: color_text = "FFFFCF"
		DamageEvent.DamageTypes.Dark: color_text = "500050"
	if as_text:
		return color_text
	return Color(color_text)

static func get_damage_icon(damage_type)->Texture2D:
	if damage_type is String:
		damage_type = DamageEvent.DamageTypes.get(damage_type)
	var damage_icon = "res://assets/Sprites/UI/SymbolIcons/PhyDamageSymbol.png"
	match damage_type:
		DamageEvent.DamageTypes.Slash: damage_icon = "res://assets/Sprites/UI/SymbolIcons/DmgSymbol_Slash.png"
		DamageEvent.DamageTypes.Blunt: damage_icon = "res://assets/Sprites/UI/SymbolIcons/DmgSymbol_Blunt.png"
		DamageEvent.DamageTypes.Pierce: damage_icon = "res://assets/Sprites/UI/SymbolIcons/DmgSymbol_Pierce.png"
		DamageEvent.DamageTypes.Crash: damage_icon = "res://assets/Sprites/UI/SymbolIcons/DmgSymbol_Crash.png"
		DamageEvent.DamageTypes.Fire: damage_icon = "res://assets/Sprites/UI/SymbolIcons/DmgSymbol_Fire.png"
		DamageEvent.DamageTypes.Cold: damage_icon = "res://assets/Sprites/UI/SymbolIcons/DmgSymbol_Cold.png"
		DamageEvent.DamageTypes.Shock: damage_icon = "res://assets/Sprites/UI/SymbolIcons/DmgSymbol_Shock.png"
		DamageEvent.DamageTypes.Poison: damage_icon = "res://assets/Sprites/UI/SymbolIcons/DmgSymbol_Poison.png"
		DamageEvent.DamageTypes.Light: damage_icon = "res://assets/Sprites/UI/SymbolIcons/DmgSymbol_Light.png"
		DamageEvent.DamageTypes.Dark: damage_icon = "res://assets/Sprites/UI/SymbolIcons/DmgSymbol_Dark.png"
		DamageEvent.DamageTypes.Chaos: damage_icon = "res://assets/Sprites/UI/SymbolIcons/DmgSymbol_Chaos.png"
		DamageEvent.DamageTypes.Psycic: damage_icon = "res://assets/Sprites/UI/SymbolIcons/DmgSymbol_Psycic.png"
	return SpriteCache.get_sprite(damage_icon)

static func get_min_max_damage(actor:BaseActor, damage_data:Dictionary)->Array:
	var base_damage = 0
	var attack_stat = damage_data.get("AtkStat")
	if (attack_stat as String).to_lower() == "fixed":
		base_damage = damage_data.get('BaseDamage')
	else:
		base_damage = actor.stats.base_damge_from_stat(attack_stat)
	
	var attack_power:float = damage_data.get("AtkPwrBase", 100) / 100.0
	if damage_data.has("AtkPwrStat"):
		attack_power = actor.stats.get_stat(damage_data["AtkPwrStat"], 1)
	var attack_power_range:float = damage_data.get("AtkPwrRange", 0) / 100.0
	var attack_power_scale :float= damage_data.get("AtkPwrScale", 1)
	var min_power = attack_power - attack_power_range
	var max_power = attack_power + attack_power_range
	var min_dam = ceili(float(base_damage) * min_power * attack_power_scale)
	var max_dam = ceili(float(base_damage) * max_power * attack_power_scale)
	if damage_data.get("DisplayAsCrit", false):
		var crit_mod = actor.stats.get_stat(StatHelper.CritMod, 1)
		min_dam = ceili(float(min_dam) * crit_mod)
		max_dam = ceili(float(max_dam) * crit_mod)
	return [min_dam, max_dam]

## Roll damage and return a DamageEvent. 
## Damage mods from Actors will be appllied (by default), but those from Attack Mods must be provided 
static func roll_for_damage(
		damage_data:Dictionary, 
		attacker:BaseActor, 
		defender:BaseActor, 
		source_tag_chain:SourceTagChain, 
		game_state:GameStateData,
		extra_damage_mods:Dictionary = {},
		actor_atk_mods_provided:bool=false
	)->DamageEvent:
	# Add Damage mods from Actors if not provided 
	if not actor_atk_mods_provided:
		var attacker_mods = attacker.get_damage_mods()
		for mod_key:String in attacker_mods.keys():
			if not extra_damage_mods.has(mod_key):
				extra_damage_mods[mod_key] = attacker_mods[mod_key]
		var defender_mods = attacker.get_damage_mods()
		for mod_key:String in defender_mods.keys():
			if not extra_damage_mods.has(mod_key):
				extra_damage_mods[mod_key] = defender_mods[mod_key]
	
	# Create DamageEvent
	var damage_event = DamageEvent.new(damage_data, attacker, defender, source_tag_chain)
	
	# Add applicable Damage Mods
	for damage_mod_key in extra_damage_mods.keys():
		var damage_mod:Dictionary = extra_damage_mods[damage_mod_key]
		if does_damage_mod_apply(damage_mod, attacker, defender, damage_data, source_tag_chain, game_state):
			damage_event.add_damage_mod(damage_mod)
	
	# --- Damage Calc Order ---
	# 1) Get applied power
	# 2) Raw damage = attack_power * applied power
	# 3) Apply Armor/Ward resuction
	# 4) Apply Damage MOds
	# 5) Apply DamageType Resistances
	# 5) Resolve Crit and Block
	
	# Calc raw damage
	var max_power = float(damage_event.attack_power + damage_event.attack_power_range) / 100.0
	var min_power = float(damage_event.attack_power - damage_event.attack_power_range) / 100.0
	damage_event.applied_power = randf_range(min_power, max_power) * damage_event.attack_power_scale
	
	# Get Damage Resistance
	damage_event.defender_resistance = defender.stats.get_damage_resistance(damage_event.damage_type)
	var resistance_reduction = 1.0 - (float(damage_event.defender_resistance) / 100.0)
	
	
	# Get the defend's Armor or Ward
	if damage_event.defense_type == DamageEvent.DefenseType.Armor:
		damage_event.defense_value = defender.stats.get_stat('Armor')
	if damage_event.defense_type == DamageEvent.DefenseType.Ward:
		damage_event.defense_value = defender.stats.get_stat('Ward')
	damage_event.defense_reduction = 1.0 - (float(damage_event.defense_value) / 100.0)
	
	# Raw Damage
	var working_damage = damage_event.base_damage * damage_event.applied_power
	damage_event.raw_damage = working_damage
	
	# Apply armor
	working_damage = working_damage * damage_event.defense_reduction
	damage_event.damage_after_armor = working_damage
	
	# Apply mods
	var add_to = 0.0
	var scale_by = 1.0
	for mod in damage_event.damage_mods.values():
		if mod.get("ModType") == "Add":
			add_to += mod.get("Value", 0)
		if mod.get("ModType") == "Scale":
			scale_by *= mod.get("Value", 1)
		
	working_damage  = (working_damage + add_to) * scale_by
	damage_event.damage_after_mods = working_damage
	
	# Apply Resistance
	working_damage = working_damage * resistance_reduction
	damage_event.damage_after_resistance = working_damage
	
	damage_event.final_damage = working_damage
	return damage_event

static func does_damage_mod_apply(damage_mod:Dictionary, attacker:BaseActor, defender:BaseActor, damage_data:Dictionary, source_tag_chain:SourceTagChain, game_state:GameStateData)->bool:
	var conditions = damage_mod.get('Conditions', null)
	var mod_source_actor = damage_mod.get('SourceActorId', null)
	#var mod_source_faction = damage_mod.get('SourceActorTeam', null)
	if not conditions:
		return false
	
	var damage_type = damage_data['DamageType']
	var damage_filter = conditions.get("DamageTypes", [])
	if damage_filter.size() > 0 and not damage_filter.has(damage_type):
		return false
	
	# Check Defender Team Filters
	var defender_team_filters = conditions.get("DefenderTeamFilters", [])
	if not TagHelper.check_team_filter(mod_source_actor, defender_team_filters, defender, game_state):
		return false
			
	# Check Attacker Team Filters
	if attacker:
		var attack_team_filters = conditions.get("AttackerTeamFilters", [])
		if not TagHelper.check_team_filter(mod_source_actor, attack_team_filters, attacker, game_state):
			return false
	
	# Check Defender Tag Filters
	var defender_tag_filters = conditions.get("DefenderTagFilters", [])
	for tag_filter in defender_tag_filters:
		if not SourceTagChain.filters_accept_tags(tag_filter, defender.get_tags()):
			return false
			
	# Check Source Tag Filters
	var source_tag_filters = conditions.get("SourceTagFilters", [])
	for source_tag_filter in source_tag_filters:
		if not SourceTagChain.filters_accept_tags(source_tag_filter, source_tag_chain.get_all_tags()):
			return false
	
	return true

static func _order_damage_mods(mods:Array):
	var add_list = []
	var scale_list = []
	for mod:BaseDamageMod in mods:
		if mod.mod_type == BaseDamageMod.ModTypes.Add:
			add_list.append(mod)
		if mod.mod_type == BaseDamageMod.ModTypes.Scale:
			scale_list.append(mod)
	add_list.append_array(scale_list)
	return add_list

const ARMOR_STRETCH:float = 30
const ARMOR_SCALE:float = 80
static func calc_armor_reduction(armor)->float:
	#var val = (log((armor+ARMOR_STRETCH)/ARMOR_STRETCH) / log(10)) * ARMOR_SCALE
	return 1.0-(float(armor)/100.0)
