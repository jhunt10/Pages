class_name DamageHelper

const LOGGING = false

const STAT_BALENCE:int = 100
const ARMOR_STRETCH:float = 30
const ARMOR_SCALE:float = 80

static func handle_attack(attacker:BaseActor, defender:BaseActor, damage_data:Dictionary, 
							source_tag_chain:SourceTagChain, game_state:GameStateData):
	
	var base_damage = 0
	var attack_stat = damage_data.get("AtkStat", null)
	if attack_stat != null and attack_stat != "Custom":
		base_damage = attacker.stats.base_damge_from_stat(attack_stat)
	else:
		base_damage = damage_data.get("BaseDamage", 0)
	handle_damage(attacker, base_damage, defender, damage_data, source_tag_chain, game_state)

static func handle_damage(source, base_damage:int, defender:BaseActor, damage_data:Dictionary, 
							source_tag_chain:SourceTagChain, game_state:GameStateData):
	var damage_event = DamageEvent.new(damage_data, source, base_damage, defender,source_tag_chain, game_state)
	
	var damage = DamageHelper._calc_damage_for_event(damage_event)
	defender.stats.apply_damage(damage_event.final_damage, source)
	defender.effects.trigger_damage_taken(game_state, damage_event)
	# TODO: Acccuracy and chance to apply effects
	if source is BaseActor:
		var source_actor:BaseActor = source as BaseActor
		source_actor.effects.trigger_damage_dealt(game_state, damage_event)
	
	var damage_effect = damage_data.get("DamageEffect", null)
	if damage_effect:
		CombatRootControl.Instance.create_damage_effect(defender, damage_effect, damage)
	

static func _calc_damage_for_event(event:DamageEvent):
	#var attacker = event.attacker
	var defender = event.defender
	
	# Calc raw damage
	var attack_power:float = (float(event._attack_power)/100.0) + randf_range(-event._damage_variance, event._damage_variance)
	event.raw_damage = event.base_damage * attack_power
	
	# Get the defend's Armor or Ward
	var defense_armor = 0
	if event.defense_type == DamageEvent.DefenseType.Armor:
		defense_armor = defender.stats.get_stat('Armor')
	if event.defense_type == DamageEvent.DefenseType.Ward:
		defense_armor = defender.stats.get_stat('Ward')
	var armor_reduction = calc_armor_reduction(defense_armor)
	event.damage_after_armor = event.raw_damage * armor_reduction
	
	# Get all tags that apply to the attack  and defense
	var attack_tags = event.source_tag_chain.get_all_tags()
	var defend_tags = defender.get_tags()
		
	
	# Get and apply all "OnDealDamage" mods from the attacker
	event.damage_after_attack_mods = event.damage_after_armor
	
	# Damage is coming from another actor
	if event.source is BaseActor:
		# Add Ally or Enemy tag
		var attacker = event.source as BaseActor
		if event.source.FactionIndex == defender.FactionIndex:
			attack_tags.append("Ally")
			defend_tags.append("Ally")
		else:
			attack_tags.append("Enemy")
			defend_tags.append("Enemy")
		var attacker_damage_mods = attacker.effects.get_on_deal_damage_mods()
		attacker_damage_mods = _order_damage_mods(attacker_damage_mods)
		for mod:BaseDamageMod in attacker_damage_mods:
			if mod.is_valid_in_case(false, attack_tags, defend_tags, event):
				event.damage_after_attack_mods = mod.apply_mod(event.damage_after_attack_mods, event)
	
	# Get and apply all "OnTakeDamage" mods from the defender
	event.damage_after_defend_mods = event.damage_after_attack_mods
	var defender_damage_mods = defender.effects.get_on_take_damage_mods()
	defender_damage_mods = _order_damage_mods(defender_damage_mods)
	for mod:BaseDamageMod in defender_damage_mods:
		if mod.is_valid_in_case(true, attack_tags, defend_tags, event):
			event.damage_after_defend_mods = mod.apply_mod(event.damage_after_defend_mods, event)
	if LOGGING:
		print("DamageHelper: base_damage: %s | raw_damage: %s | after_armor: %s" % [event.base_damage, event.raw_damage, event.damage_after_armor])
	event.final_damage = event.damage_after_defend_mods
	return event.final_damage

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
	

static func calc_armor_reduction(armor)->float:
	var log_x = log(armor)
	var val = (log((armor+ARMOR_STRETCH)/ARMOR_STRETCH) / log(10)) * ARMOR_SCALE
	return 1-(val/100)
