class_name DamageHelper

const LOGGING = true

const STAT_BALENCE:int = 100

static func get_min_max_damage(actor:BaseActor, damage_data:Dictionary)->Array:
	var base_damage = 0
	var attack_stat = damage_data.get("AtkStat")
	if attack_stat == "Fixed":
		base_damage = damage_data.get('BaseDamage')
	else:
		base_damage = actor.stats.base_damge_from_stat(attack_stat)
	
	var attack_power = damage_data.get("AtkPower", 100) / 100
	var damage_variance = damage_data.get("DamageVarient", 0)
	var avg_dam = base_damage * attack_power
	var min_dam = ceili(avg_dam * (1 - damage_variance))
	var max_dam = ceili(avg_dam * (1 + damage_variance))
	return [min_dam, max_dam]

static func handle_push_damage(moving_actor:BaseActor, pushed_actor:BaseActor, game_state:GameStateData):
	var winner = moving_actor
	var loser = pushed_actor
	var base_damage = winner.stats.get_stat("Strength", 0)
	if moving_actor.stats.get_stat("Mass") < pushed_actor.stats.get_stat("Mass"):
		loser = moving_actor
		winner = pushed_actor
		base_damage = winner.stats.get_stat("Strength", 0) / 2
	var damage_data = {
		"AtkPower": 10,
		"AtkStat": "Strength",
		"BaseDamage": base_damage,
		"DamageEffect": "Blunt_DamageEffect",
		"DamageType": "Crash",
		"DamageVarient": 0,
		"DefenseType": "Armor"
	}
	var tag_chain = SourceTagChain.new().append_source(SourceTagChain.SourceTypes.Actor, winner)
	handle_damage(winner, loser, damage_data, tag_chain, game_state)





static func roll_for_damage(damage_data:Dictionary, attacker:BaseActor, defender:BaseActor, source_tag_chain:SourceTagChain, damage_mods:Dictionary)->DamageEvent:
	var damage_event = DamageEvent.new(damage_data, attacker, defender, source_tag_chain)
	# Apply Damage mods
	var applied_mods = []
	for damage_mod_key in damage_mods.keys():
		var damage_mod:Dictionary = damage_mods[damage_mod_key]
		if does_damage_mod_apply(damage_mod, attacker, defender, damage_data, source_tag_chain):
			damage_event.add_damage_mod(damage_mod)
	
	# --- Damage Calc Order ---
	# 1) Get applied power from damage_variance
	# 2) Raw damage = attack_power * applied power
	# 3) Apply Armor/Ward resuction
	# 4) Apply Damage MOds
	# 5) Apply DamageType Resistances
	# 5) Resolve Crit and Block
	
	# Calc raw damage
	var float_power = float(damage_event.attack_power)/100.0
	damage_event.applied_power = (float_power + (float_power * randf_range(-damage_event.damage_variance, damage_event.damage_variance)))
	
	# Get Damage Resistance
	damage_event.defender_resistance = defender.stats.get_damage_resistance(damage_event.damage_type)
	var resistance_reduction = 1.0 - (damage_event.defender_resistance / 100)
	
	
	# Get the defend's Armor or Ward
	if damage_event.defense_type == DamageEvent.DefenseType.Armor:
		damage_event.defense_value = defender.stats.get_stat('Armor')
	if damage_event.defense_type == DamageEvent.DefenseType.Ward:
		damage_event.defense_value = defender.stats.get_stat('Ward')
	damage_event.defense_reduction = 1.0 - (damage_event.defense_value / 100)
	
	# Raw Damage
	var working_damage = damage_event.base_damage * damage_event.applied_power
	damage_event.raw_damage = working_damage
	
	# Apply armor
	working_damage = working_damage * damage_event.defense_reduction
	damage_event.damage_after_armor = working_damage
	
	# Apply mods
	var add_to = 0.0
	var scale_by = 1.0
	for mod in applied_mods:
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

static func does_damage_mod_apply(damage_mod:Dictionary, attacker:BaseActor, defender:BaseActor, damage_data:Dictionary, source_tag_chain:SourceTagChain)->bool:
	var conditions = damage_mod.get('Conditions', null)
	var mod_source_actor = damage_mod.get('SourceActorId', null)
	var mod_source_faction = damage_mod.get('SourceActorFaction', null)
	if not conditions:
		return false
	
	var damage_type = damage_data['DamageType']
	var damage_filter = conditions.get("DamageTypes", [])
	if damage_filter.size() > 0 and not damage_filter.has(damage_type):
		return false
	
	# Check Attacker Faction Filters
	if attacker:
		var attack_faction_filters = conditions.get("AttackerFactionFilters", [])
		if not FilterHelper.check_faction_filter(mod_source_actor, mod_source_faction, attack_faction_filters, attacker):
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
	








static func handle_damage(source, defender:BaseActor, damage_data:Dictionary, 
							source_tag_chain:SourceTagChain, game_state:GameStateData, 
							attack_event:AttackEvent=null, create_VFX:bool = true)->DamageEvent:
	## Need to get base damage before making event because  (BECAUSE WHY? Thanks old me)
	#var base_damage = 0
	#var attack_stat = damage_data.get("AtkStat")
	#if not attack_stat:
		#printerr("DamageHelper: No AtkStat found on damage data")
	#elif attack_stat.begins_with('@'):
		#base_damage = source.stats.base_damge_from_stat(attack_stat)
	
	var damage_event = DamageEvent.new(damage_data, source, defender,source_tag_chain)
	
	if attack_event:
		if attack_event.is_evade:
			printerr("DamageHelper.handle_damage: Called on Evaded attack")
			return damage_event
		# Appy Crit Mod
		if attack_event.is_crit and not attack_event.is_blocked:
			damage_event.final_damage = damage_event.final_damage * attack_event.attcker_crit_mod
		# Apply Block Mod
		if attack_event.is_blocked and not attack_event.is_crit:
			# Don't apply Block if damage would heal
			if damage_event.final_damage > 0:
				damage_event.final_damage = damage_event.final_damage * attack_event.defender_block_mod
	
	print("DamageHelper.hand_damage: Real final applied damage: %s" % [damage_event.final_damage])
	defender.stats.apply_damage(damage_event.final_damage)
	damage_event.was_applied = true
	defender.effects.trigger_damage_taken(game_state, damage_event)
	
	if source is BaseActor:
		var source_actor:BaseActor = source as BaseActor
		source_actor.effects.trigger_damage_dealt(game_state, damage_event)
		defender.aggro.add_threat_from_actor(source_actor, damage_event.final_damage)
	
	if create_VFX:
		var damage_effect = damage_data.get("DamageEffect", null)
		var damage_effect_data = damage_data.get("DamageEffectData", {})
		if damage_effect:
			if damage_event.final_damage < 0:
				damage_effect_data['DamageTextType'] = FlashTextController.FlashTextType.Healing_Dmg
			elif source_tag_chain.has_tag("DOT"):
				damage_effect_data['DamageTextType'] = FlashTextController.FlashTextType.DOT_Dmg
			elif attack_event.final_damage_mod > 1:
				damage_effect_data['DamageTextType'] = FlashTextController.FlashTextType.Crit_Dmg
			elif attack_event.final_damage_mod < 1:
				damage_effect_data['DamageTextType'] = FlashTextController.FlashTextType.Blocked_Dmg
			else:
				damage_effect_data['DamageTextType'] = FlashTextController.FlashTextType.Normal_Dmg
			if source is BaseActor:
				damage_effect_data['SourceActorId'] = source.Id
			damage_effect_data['DamageNumber'] = 0 - damage_event.final_damage
			VfxHelper.create_damage_effect(defender, damage_effect, damage_effect_data)
	return damage_event
	

static func _order_damage_mods(mods:Array):
	var add_list = []
	var scale_list = []
	var overridde_list = []
	for mod:BaseDamageMod in mods:
		if mod.mod_type == BaseDamageMod.ModTypes.Add:
			add_list.append(mod)
		if mod.mod_type == BaseDamageMod.ModTypes.Scale:
			scale_list.append(mod)
	add_list.append_array(scale_list)
	return add_list

static func get_relative_attack_direction(attacker_pos:MapPos, defender_pos:MapPos)->AttackHandler.AttackDirection:
	if defender_pos == null:
		#TODO: Missiles from dead actors
		printerr("Defender posision not provided")
		return AttackHandler.AttackDirection.Front
	if attacker_pos == null:
		#TODO: Missiles from dead actors
		printerr("Attcker posision not provided")
		return AttackHandler.AttackDirection.Front
	var x_change = defender_pos.x - attacker_pos.x
	var y_change = defender_pos.y - attacker_pos.y
	var front_back_change = 0
	var right_left_change = 0
	if defender_pos.dir == MapPos.Directions.North:
		front_back_change = y_change
		right_left_change = x_change
	elif defender_pos.dir == MapPos.Directions.East:
		front_back_change = -x_change
		right_left_change = -y_change
	elif defender_pos.dir == MapPos.Directions.South:
		front_back_change = -y_change
		right_left_change = -x_change
	elif defender_pos.dir == MapPos.Directions.West:
		front_back_change = x_change
		right_left_change = y_change
	
	if abs(front_back_change) >= abs(right_left_change):
		if front_back_change >= 0:
			return AttackHandler.AttackDirection.Front
		else:
			return AttackHandler.AttackDirection.Back
	else:
		return AttackHandler.AttackDirection.Flank

const ARMOR_STRETCH:float = 30
const ARMOR_SCALE:float = 80
static func calc_armor_reduction(armor)->float:
	#var val = (log((armor+ARMOR_STRETCH)/ARMOR_STRETCH) / log(10)) * ARMOR_SCALE
	return 1.0-(float(armor)/100.0)

static func build_damage_vfx_data(attack_event:AttackEvent, damage_event:DamageEvent, damage_data:Dictionary)->Dictionary:
	var damage_vfx_key = damage_data.get("DamageEffect", null)
	var damage_vfx_data = damage_data.get("DamageEffectData", {}).duplicate()
	if damage_vfx_key:
		damage_vfx_data['VfxKey'] = damage_vfx_key
		if damage_event.final_damage < 0:
			damage_vfx_data['DamageTextType'] = FlashTextController.FlashTextType.Healing_Dmg
		elif attack_event.is_crit and not attack_event.is_blocked:
			damage_vfx_data['DamageTextType'] = FlashTextController.FlashTextType.Crit_Dmg
		elif attack_event.is_blocked and not attack_event.is_crit:
			damage_vfx_data['DamageTextType'] = FlashTextController.FlashTextType.Blocked_Dmg
		else:
			damage_vfx_data['DamageTextType'] = FlashTextController.FlashTextType.Normal_Dmg
		damage_vfx_data['DamageNumber'] = 0 - damage_event.final_damage
		damage_vfx_data['SourceActorId'] = attack_event.attacker.Id
	return damage_vfx_data
