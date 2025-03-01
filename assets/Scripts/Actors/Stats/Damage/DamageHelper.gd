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
	

static func handle_attack(attacker:BaseActor, defender:BaseActor, damage_datas, 
							source_tag_chain:SourceTagChain, game_state:GameStateData, 
							target_parameters:TargetParameters,
							attack_from_spot_override:MapPos = null)->AttackEvent:
	print("################ Attacking #########################")
	print("Handing Attack: %s to %s " % [attacker.details.display_name, defender.details.display_name])
	
	
	var attack_direction = null
	if target_parameters.has_area_of_effect():
		attack_direction = AttackEvent.AttackDirection.AOE
	else:
		var attacker_pos = attack_from_spot_override
		if !attacker_pos:
			attacker_pos = game_state.get_actor_pos(attacker)
		var defender_pos = game_state.get_actor_pos(defender)
		attack_direction = get_relative_attack_direction(attacker_pos, defender_pos)
	
	var damage_list = []
	if damage_datas is Array:
		damage_list = damage_datas
	elif damage_datas is Dictionary:
		if damage_datas.values()[0] is Dictionary:
			for d_data_key in damage_datas.keys():
				var d_data = damage_datas[d_data_key].duplicate()
				if not d_data.keys().has("DamageDataKey"):
					d_data['DamageDataKey'] = d_data_key
				damage_list.append(d_data)
		else:
			damage_list = [damage_datas]
	
	# TODO:Cover
	var attack_event = AttackEvent.new(attacker, defender, attack_direction, false, source_tag_chain, damage_list)
	
	# Apply Pre-Roll effects
	attacker.effects.trigger_attack(game_state, attack_event)
	defender.effects.trigger_attack(game_state, attack_event)
	
	attack_event.roll_for_hit()
	
	# Apply Post-Roll effects
	attacker.effects.trigger_attack(game_state, attack_event)
	defender.effects.trigger_attack(game_state, attack_event)
	print("Attack Results: | Hit: %s" % [ attack_event.is_hit])
	
	# On Miss
	if not attack_event.is_hit:
		if attack_event.is_evade:
			CombatRootControl.Instance.create_flash_text_on_actor(defender, "Evade", Color.GREEN)
		else:
			CombatRootControl.Instance.create_flash_text_on_actor(attacker, "Miss", Color.RED)
	# On Hit
	else:
		# Resolve Damage
		var attacK_damage_datas = attack_event.get_damage_datas()
		print("Found %s Damage Datas to apply | Final Damage Mod: %s" % [attacK_damage_datas.size(), attack_event.final_damage_mod])
		for damage_data in attacK_damage_datas:
			var damage_event = handle_damage(attacker, defender, damage_data, source_tag_chain, game_state, attack_event.final_damage_mod)
			if damage_event:
				attack_event.damage_events.append(damage_event)
		
	attack_event.attack_stage = AttackEvent.AttackStage.Resolved
	
	# Trigger Post-Attack effects
	attacker.effects.trigger_attack(game_state, attack_event)
	defender.effects.trigger_attack(game_state, attack_event)
	
	print("################## Attack Done #######################")
	return attack_event

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

static func handle_damage(source, defender:BaseActor, damage_data:Dictionary, 
							source_tag_chain:SourceTagChain, game_state:GameStateData, final_damage_mod:float = 1)->DamageEvent:
	# Need to get base damage before making event because  
	var base_damage = 0
	var attack_stat = damage_data.get("AtkStat")
	if not attack_stat:
		printerr("DamageHelper: No AtkStat found on damage data")
	elif attack_stat.begins_with('@'):
		base_damage = source.stats.base_damge_from_stat(attack_stat)
	
	var damage_event = DamageEvent.new(damage_data, source, defender,source_tag_chain, game_state)
	
	var damage = damage_event.final_damage * final_damage_mod
	print("DamageHelper.hand_damage: Real final applied damage: %s" % [damage])
	defender.stats.apply_damage(damage_event.final_damage, source)
	defender.effects.trigger_damage_taken(game_state, damage_event)
	# TODO: Acccuracy and chance to apply effects
	if source is BaseActor:
		var source_actor:BaseActor = source as BaseActor
		source_actor.effects.trigger_damage_dealt(game_state, damage_event)
	
	var damage_effect = damage_data.get("DamageEffect", null)
	if damage_effect:
		var damage_color = Color.RED
		if final_damage_mod > 1:
			damage_color = Color.YELLOW
		elif final_damage_mod < 1:
			damage_color = Color.BLUE
		CombatRootControl.Instance.create_damage_effect(defender, damage_effect, damage, source, damage_color)
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

static func get_relative_attack_direction(attacker_pos:MapPos, defender_pos:MapPos)->AttackEvent.AttackDirection:
	if defender_pos == null:
		#TODO: Missiles from dead actors
		printerr("Defender posision not provided")
		return AttackEvent.AttackDirection.Front
	if attacker_pos == null:
		#TODO: Missiles from dead actors
		printerr("Attcker posision not provided")
		return AttackEvent.AttackDirection.Front
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
			return AttackEvent.AttackDirection.Front
		else:
			return AttackEvent.AttackDirection.Back
	else:
		return AttackEvent.AttackDirection.Flank

const ARMOR_STRETCH:float = 30
const ARMOR_SCALE:float = 80
static func calc_armor_reduction(armor)->float:
	#var val = (log((armor+ARMOR_STRETCH)/ARMOR_STRETCH) / log(10)) * ARMOR_SCALE
	return 1.0-(float(armor)/100.0)
