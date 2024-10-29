class_name DamageHelper

const STAT_BALENCE:int = 100
const ARMOR_STRETCH:float = 30
const ARMOR_SCALE:float = 80


#static func get_target_params(key:String, actor:BaseActor, action:BaseAction, effect:BaseEffect):
	#if key == "Weapon":
		#var weapon = actor.equipment.get_item_in_slot(BaseEquipmentItem.EquipmentSlots.Weapon)
		#if !weapon:
			#return null
		#return (weapon as BaseWeaponEquipment).get_damage_data()
	#if action:
		#var parms = action.get_damage_data(key)
		#if parms: return parms
	#if effect:
		#var parms = effect.get_tar(key)
		#if parms: return parms
	#return 


static func handle_damage(attacker:BaseActor, defender:BaseActor, damage_data:Dictionary, 
							source_tag_chain:SourceTagChain, game_state:GameStateData):
	var base_damage = damage_data.get("BaseDamage", null)
	if base_damage == null:
		printerr("DamageHelper.handle_damage: No 'BaseDamage' found.")
		return
	
	var attack_stat = damage_data.get("AtkStat", null)
	if base_damage == null:
		printerr("DamageHelper.handle_damage: No 'BaseDamage' found.")
		return
		
	var damage_type = damage_data.get("DamageType", null)
	if damage_type == null:
		printerr("DamageHelper.handle_damage: No 'DamageType' found.")
		return
		
	var defense_type = damage_data.get("DefenseType", DamageEvent.DefenseType.None)
	if defense_type == null:
		printerr("DamageHelper.handle_damage: No 'DefenseType' found.")
		return
		
	var damage_event = DamageEvent.new(attacker, defender,source_tag_chain, game_state, 
									base_damage, attack_stat, damage_type, defense_type)
	
	var damage = DamageHelper._calc_damage_for_event(damage_event)
	# TODO: Acccuracy and chance to apply effects
	defender.stats.apply_damage(damage, damage_type, attacker)
	
	var damage_effect = damage_data.get("DamageEffect", null)
	if damage_effect:
		CombatRootControl.Instance.create_damage_effect(defender, damage_effect, damage)
	

static func _calc_damage_for_event(event:DamageEvent):
	var attacker = event.attacker
	var defender = event.defender
	
	var attack_stat_val = attacker.stats.get_stat(event.attack_stat)
	event.raw_damage = event.base_damage * ((attack_stat_val + STAT_BALENCE) / (STAT_BALENCE))
	
	var defense_armor = 0
	if event.defense_type == DamageEvent.DefenseType.Armor:
		defense_armor = defender.stats.get_stat('Armor')
	if event.defense_type == DamageEvent.DefenseType.Resist:
		defense_armor = defender.stats.get_stat('Resist')
	var armor_reduction = calc_armor_reduction(defense_armor)
	event.damage_after_armor = event.raw_damage * armor_reduction
	
	var attack_tags = event.source_tag_chain.get_all_tags()
	var defend_tags = defender.get_tags()
	if attacker.FactionIndex == defender.FactionIndex:
		attack_tags.append("Ally")
		defend_tags.append("Ally")
	else:
		attack_tags.append("Enemy")
		defend_tags.append("Enemy")
	
	event.damage_after_attack_mods = event.damage_after_armor
	var attacker_damage_mods = attacker.effects.get_on_deal_damage_mods()
	attacker_damage_mods = _order_damage_mods(attacker_damage_mods)
	for mod:BaseDamageMod in attacker_damage_mods:
		if mod.is_valid_in_case(false, attack_tags, defend_tags, event):
			event.damage_after_attack_mods = mod.apply_mod(event.damage_after_attack_mods, event)
	
	event.damage_after_defend_mods = event.damage_after_attack_mods
	var defender_damage_mods = defender.effects.get_on_take_damage_mods()
	defender_damage_mods = _order_damage_mods(defender_damage_mods)
	for mod:BaseDamageMod in defender_damage_mods:
		if mod.is_valid_in_case(true, attack_tags, defend_tags, event):
			event.damage_after_defend_mods = mod.apply_mod(event.damage_after_defend_mods, event)
	
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
