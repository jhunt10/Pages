class_name AttackHandler

const LOGGING = true

enum AttackDirection {Front, Flank, Back, AOE}
enum AttackStage 
{
	## Attack Event has just been created
	Created,
	## Attack Event has rolled for Hit / Miss / Evade / Crit / Block 
	RolledForHit,
	## Attack Event has calculated/rolled Damage
	RolledForDamage,
	## Attack Event has rolled Effect Application
	RolledForEffects,
	## Attack Event has applied Damage and Effects
	Resolved
}

static func handle_attack(
	attacker:BaseActor, 
	defenders:Array,
	attack_details:Dictionary, 
	damage_datas:Dictionary, 
	effect_datas:Dictionary,  
	source_tag_chain:SourceTagChain,
	target_parameters:TargetParameters,
	game_state:GameStateData, 
	attack_from_spot_override:MapPos = null 
):
	# Prep directional data
	var attack_posision_data = {}
	var attacker_pos = attack_from_spot_override
	if !attacker_pos:
		attacker_pos = game_state.get_actor_pos(attacker)
	
	var attack_mods = {}
	var stat_mods = {}
	
	# get unique list of all Actors involed in attack
	var attacker_included_in_defenders = false
	var all_unique_actors = [attacker] # Attacker might be includeded in defenders
	for defender in defenders:  # A Defender may be includeded multiple times
		if defender == attacker:
			attacker_included_in_defenders = true
		if not all_unique_actors.has(defender): 
			all_unique_actors.append(defender)
	
	# Get attack direction for each defender
	for actor:BaseActor in all_unique_actors:
		if actor == attacker and not attacker_included_in_defenders:
			continue
		# Cache Attack Directions and cover for all defenders
		var attack_direction = AttackHandler.AttackDirection.Front
		if actor != attacker or attacker_included_in_defenders:
			attack_posision_data [actor.Id] = {}
			# TODO: Cover
			attack_posision_data[actor.Id]['HasCover'] = false
			# Has AOE area 
			#TODO: Decide what defines is_AOE
			if target_parameters and target_parameters.has_area_of_effect():
				attack_direction = AttackHandler.AttackDirection.AOE
			else:
				var defender_pos = game_state.get_actor_pos(actor)
				attack_direction = get_relative_attack_direction(attacker_pos, defender_pos)
			attack_posision_data[actor.Id]['AttackDirection'] = attack_direction
		
	for actor:BaseActor in all_unique_actors:
		var actor_attack_mods = actor.get_attack_mods()
		for actor_attack_mod_key in actor_attack_mods.keys():
			var attack_mod = actor_attack_mods[actor_attack_mod_key]
			# Check if mod applies to attack
			if _does_attack_mod_apply(attack_mod, attacker, defenders, source_tag_chain, attack_posision_data):
				var mod_id = attack_mod['AttackModId']
				attack_mods[mod_id] = attack_mod
				# Cache Stat Mods now to avoid another loop
				var sub_stat_mods = _get_stat_mods_from_attack_mod(attack_mod)
				for sub_stat_mod_key in sub_stat_mods.keys():
					stat_mods[sub_stat_mod_key] = sub_stat_mods[sub_stat_mod_key]
		# Done with attacker
			continue
			
	
	# Apply Stat mods to appropiate Actors 
	for actor:BaseActor in all_unique_actors:
		for stat_mod_id in stat_mods.keys():
			var stat_mod = stat_mods[stat_mod_id]
			if _does_attack_stat_mod_apply_to_actor(stat_mod, actor, source_tag_chain):
				actor.stats.add_temp_stat_mod(stat_mod_id, stat_mod, false)
		actor.stats.apply_temp_stat_mods()
	
	var attack_event = AttackEvent.new(
		attacker, 
		defenders, 
		attack_posision_data, 
		attack_details, 
		source_tag_chain, 
		damage_datas, 
		effect_datas,
		attack_mods # Can probably filter down to Damage mods since StatMods have been applied
	)
	
	#### Steps #####
	# 1. Roll for Hit
	# 2. Roll for Damage
	# 3. Roll for Effects
	# 4. Apply Damage and Effects
	# 5. Create Vfxs
	
	# Trigger Pre Attack Roll Effects
	for actor in all_unique_actors:
		actor.effects.trigger_attack(attack_event, game_state)
	
	# Loop through each Defender preform roles
	for defender:BaseActor in defenders:
		_roll_for_hit(attack_event, attack_event.sub_events[defender.Id])
	attack_event.attack_stage = AttackStage.RolledForHit
	
	# Trigger Post Attack Roll Effects
	for actor in all_unique_actors:
		actor.effects.trigger_attack(attack_event, game_state)
	
	# Calculate Damage
	for defender:BaseActor in defenders:
		_roll_damage_for_attack_event(attack_event, attacker, defender)
	attack_event.attack_stage = AttackStage.RolledForDamage
	
	# Trigger Post Damage Roll Effects
	for actor in all_unique_actors:
		actor.effects.trigger_attack(attack_event, game_state)
	
	# Roll for Effects on each defender
	for defender:BaseActor in defenders:
		_roll_for_effects(attacker, defender, attack_event)
	attack_event.attack_stage = AttackStage.RolledForEffects
	
	var vfx_data_cache = {}
	
	# Trigger Post Effect Roll Effects
	for actor in all_unique_actors:
		actor.effects.trigger_attack(attack_event, game_state)
	
	# Apply damage and create effects
	for defender:BaseActor in defenders:
		var sub_event:AttackSubEvent = attack_event.sub_events[defender.Id]
		var defender_node = CombatRootControl.get_actor_node(defender.Id)
		
		var damage_vfx_cache = []
		var resisted_effect = false
		
		# Apply damage 
		for damage_event:DamageEvent in sub_event.damage_events:
			defender.stats.apply_damage(damage_event.final_damage)
			damage_event.was_applied = true
			
			# Get Damage Vfx Data
			var damage_key = damage_event.damage_data_key
			var damage_data = attack_event.damage_datas[damage_key]
			damage_vfx_cache.append(_tranlate_damage_vfx_data(attacker.Id, sub_event, damage_event, damage_data))
			
			# Ignore rest of damage if defender died
			if defender.is_dead:
				break
		
		# Create Effects
		# Skip effects if defender died
		if not defender.is_dead:
			for effect_data_key:String in attack_event.effect_datas.keys():
				# TODO: Add a "Resist" flash text for effects that triggered but failed to apply
				var effect_details:Dictionary = attack_event.effect_datas[effect_data_key]
				var effect_result:Dictionary = sub_event.applied_effect_datas.get(effect_data_key, {})
				if effect_result.get("WasApplied", false):
					var effect_key = effect_details.get("EffectKey")
					var effect_data = effect_details.get("EffectData", {})
					var effect = EffectHelper.create_effect(defender, attacker, effect_key, effect_data, game_state)
				else:
					resisted_effect = true
		
		vfx_data_cache[defender.Id] = {
			"Resisted": resisted_effect,
			"DamageVFXDatas": damage_vfx_cache
		}
				
	attack_event.attack_stage = AttackStage.Resolved
	
	# Clear Temp Stat Mods from Actors
	for actor:BaseActor in all_unique_actors:
		actor.stats.clear_temp_stat_mods()
	
	# Create Vfxs
	var attack_data_key = attack_details.get("AttackVfxKey")
	var attack_vfx_data = attack_details.get("AttackVfxData")
	for defender:BaseActor in defenders:
		var sub_event:AttackSubEvent = attack_event.sub_events[defender.Id]
		var defender_node = CombatRootControl.get_actor_node(defender.Id)
		var vfx_cache = vfx_data_cache[defender.Id]
		
		# Create "Resist" text for resisted efects
		if vfx_cache['Resisted']:
			defender_node.vfx_holder.flash_text_controller.add_flash_text("Resist", FlashTextController.FlashTextType.Blocked_Dmg)
		
		if sub_event.is_evade:
			defender_node.vfx_holder.flash_text_controller.add_flash_text("Evade", FlashTextController.FlashTextType.Blocked_Dmg)
			
		if sub_event.is_miss:
			defender_node.vfx_holder.flash_text_controller.add_flash_text("Miss", FlashTextController.FlashTextType.Blocked_Dmg)
		
		if attack_data_key:
			var vfx_source = attacker
			if attack_from_spot_override:
				var posible_actors = game_state.get_actors_at_pos(attack_from_spot_override)
				if posible_actors.size() == 1:
					vfx_source = posible_actors[0]
			var vfx_node = VfxHelper.create_vfx_on_actor(defender, attack_data_key, attack_vfx_data, vfx_source)
			for damage_vfx_cache in vfx_cache['DamageVFXDatas']:
				var damage_vfx_key = damage_vfx_cache['DamageVfxKey']
				var damage_vfx_data = damage_vfx_cache['DamageVfxData']
				vfx_node.add_chained_vfx(damage_vfx_key, damage_vfx_data)
		else:
			for damage_vfx_cache in vfx_cache['DamageVFXDatas']:
				var damage_vfx_key = damage_vfx_cache['DamageVfxKey']
				var damage_vfx_data = damage_vfx_cache['DamageVfxData']
				VfxHelper.create_damage_effect(defender, damage_vfx_key, damage_vfx_data)
		
	# Trigger After Attack Effects
	for actor in all_unique_actors:
		actor.effects.trigger_attack(attack_event, game_state)
	
	return attack_event



static func _roll_for_hit(attack_event:AttackEvent, sub_event:AttackSubEvent):
	var attack_accuracy_mod = attack_event.attack_details.get("AccuracyMod", 1)
	var net_accuracy = max(0, (attack_event.attacker_accuracy * attack_accuracy_mod) - sub_event.defender_evasion)
	
	sub_event.hit_chance = net_accuracy / 100.0
	sub_event.hit_roll = randf()
	# sub_event.is_miss = [Was invaild Target]
	sub_event.is_evade = sub_event.hit_roll > sub_event.hit_chance
	sub_event.is_crit = sub_event.hit_roll < attack_event.attacker_crit_chance
	
	var block_roll = randf()
	sub_event.is_blocked = block_roll < sub_event.defender_block_chance

static func _roll_damage_for_attack_event( attack_event:AttackEvent, attacker:BaseActor, defender:BaseActor):
	var sub_event:AttackSubEvent = attack_event.sub_events[defender.Id]
	if sub_event.is_miss or sub_event.is_evade:
		return
	# Get damage mods from AttackMods and passive mods from Attacker and Defender
	var damage_mods = {}
	for attack_mod in attack_event.attack_mods.values():
		damage_mods.merge(attack_mod.get("DamageMods", {}))
	damage_mods.merge(attacker.get_damage_mods())
	damage_mods.merge(defender.get_damage_mods())
	for damage_key in attack_event.damage_datas.keys():
		var damage_data = attack_event.damage_datas[damage_key]
		var damage_event = DamageHelper.roll_for_damage(damage_data, attacker, defender, attack_event.source_tag_chain, damage_mods)
		# Was Blocked
		if sub_event.is_blocked and not sub_event.is_crit:
			damage_event.final_damage = damage_event.damage_after_resistance * sub_event.defender_block_mod
		# Was Crit
		elif sub_event.is_crit and not sub_event.is_blocked:
			damage_event.final_damage = damage_event.damage_after_resistance * attack_event.attcker_crit_mod
		else:
			damage_event.final_damage = damage_event.damage_after_resistance
		sub_event.damage_events.append(damage_event)

## Roll for each Attack Effect for defender. 
## Results of rolls are added to sub_event.applied_effect_datas.
static func _roll_for_effects(attacker:BaseActor, defender:BaseActor, attack_event:AttackEvent):
	var sub_event:AttackSubEvent = attack_event.sub_events[defender.Id]
	
	var attack_potency_mod = attack_event.attack_details.get("PotencyMod", 1)
	var attacker_potency = attack_event.attacker_potency
	var defender_protection = sub_event.defender_protection
	var net_protection = max(0, defender_protection + (100 - (attacker_potency * attack_potency_mod)))
	
	for attack_effect_key in attack_event.effect_datas.keys():
		var attack_effect_data = attack_event.effect_datas[attack_effect_key]
		# Attack was blocked
		if sub_event.is_blocked and not attack_effect_data.get("ApplyOnBlock"):
			continue
		# Attack was evaded
		if sub_event.is_evade and not attack_effect_data.get("ApplyOnEvade"):
			continue
		# Effect does not apply to defender
		if not _can_effect_apply(attack_effect_data, attacker, defender, attack_event, sub_event ):
			continue
		var chance_to_apply = attack_effect_data.get("ApplicationChance", 1)
		var application_chance = (1-float(net_protection)/100.0) * chance_to_apply
		var roll = randf()
		var applied = roll < application_chance
		sub_event.applied_effect_datas[attack_effect_key] = {
			'WasApplied': applied,
			'ApplicationRoll': roll,
			'ApplicationChance': application_chance,
			'NetProtection': net_protection
		}

static func  _can_effect_apply(attack_effect_data:Dictionary, attacker:BaseActor, defender:BaseActor, attack_event:AttackEvent, sub_event:AttackSubEvent):
	var conditions = attack_effect_data.get("Conditions", {})
	var faction_filter = conditions.get("DefenderFactionFilters", [])
	if not FilterHelper.check_faction_filter(attack_event.attacker_id, attack_event.attacker_faction, faction_filter, defender):
		return false
	var source_tag_filters = conditions.get("DefenderTagFilters", [])
	for source_tag_filter in source_tag_filters:
		if not SourceTagChain.filters_accept_tags(source_tag_filter, attack_event.source_tag_chain.get_all_tags()):
			return false
	return true


## Returns true if Attacker, Defenders, and SourceTagChain meet all requirements of Conditions
static func _does_attack_mod_apply(attack_mod, attacker, defenders, source_tag_chain:SourceTagChain, attack_posision_data:Dictionary)->bool:
	var mod_key = attack_mod['AttackModKey']
	var conditions = attack_mod.get('Conditions', null)
	var mod_source_actor = attack_mod.get('SourceActorId', null)
	var mod_source_faction = attack_mod.get('SourceActorFaction', null)
	if conditions == null:
		printerr("AttackHandler: AttackMod '%s' missing Conditions" % [mod_key])
		return false
	if mod_source_actor == null:
		printerr("AttackHandler: AttackMod '%s' missing SourceActorId" % [mod_key])
		return false
	if mod_source_faction == null:
		printerr("AttackHandler: AttackMod '%s' missing SourceActorFaction" % [mod_key])
		return false
	
	
	# Check Attacker Faction Filters
	var attack_faction_filters = conditions.get("AttackerFactionFilters", [])
	if not FilterHelper.check_faction_filter(mod_source_actor, mod_source_faction, attack_faction_filters, attacker):
		return false
	
	# Check Source Tag Filters
	var source_tag_filters = conditions.get("SourceTagFilters", [])
	for source_tag_filter in source_tag_filters:
		if not SourceTagChain.filters_accept_tags(source_tag_filter, source_tag_chain.get_all_tags()):
			return false
	
	# Check Defender Conditions
	var all_defend_conditions_are_valid = true
	for defender_condition in conditions.get("DefendersConditions", {}):
		var require_all_defenders = defender_condition.get("RequiresAllDefenders", false)
		var faction_filter = defender_condition.get("DefenderFactionFilters", [])
		var tag_filters = defender_condition.get("DefenderTagFilters", [])
		var attack_directions_filters = defender_condition.get("AttackDirections", [])
		
		# Check each defender
		var all_defenders_are_valid = true
		var any_defenders_are_valid = false
		for defender:BaseActor in defenders:
			var position_data = attack_posision_data[defender.Id]
			var condition_is_valid_for_defender = true
			
			# Check Direction Filters
			if attack_directions_filters.size() > 0:
				var str_direction = AttackDirection.keys()[position_data['AttackDirection']]
				if not attack_directions_filters.has(str_direction):
					all_defenders_are_valid = false
					if require_all_defenders:
						break
					else:
						continue
			
			# Defender is valid faction
			if not FilterHelper.check_faction_filter(mod_source_actor, mod_source_faction, faction_filter, defender):
				all_defenders_are_valid = false
				if require_all_defenders:
					break
				else:
					continue
			for tag_filter in tag_filters:
				if not SourceTagChain.filters_accept_tags(tag_filter, defender.get_tags()):
					all_defenders_are_valid = false
					if require_all_defenders:
						break
					else:
						continue
			# If we made it this far, then defender passed all the checks
			any_defenders_are_valid = true
		# Check if all defenders were valid
		if require_all_defenders:
			if not all_defenders_are_valid:
				return false
		# Check if any defenders were valid
		elif not any_defenders_are_valid:
			return false
	# All checkes passed
	return true

static func _get_stat_mods_from_attack_mod(attack_mod:Dictionary)->Dictionary:
	var out_dict = {}
	for mod_key:String in attack_mod.get("StatMods", {}):
		var mod_data:Dictionary = attack_mod['StatMods'][mod_key]
		var can_stack = mod_data.get("Conditions", {}).get("CanStack", false)
		mod_data['SourceActorId'] = attack_mod.get("SourceActorId", null)
		mod_data['SourceActorFaction'] = attack_mod.get("SourceActorFaction", null)
		mod_data['DisplayName'] = attack_mod.get("DisplayName", "")
		var mod_id = mod_key
		if not can_stack:
			mod_id = mod_key + ":" + attack_mod.get("AttackModId")
		mod_data['StatModId'] = mod_id
		out_dict[mod_id] = BaseStatMod.create_from_data(mod_data['SourceActorId'], mod_data)
	return out_dict

static func _does_attack_stat_mod_apply_to_actor(stat_mod:BaseStatMod, actor:BaseActor, attack_source_tag_chain:SourceTagChain)->bool:
	if !stat_mod:
		return false
	var conditions = stat_mod.condition_data
	var mod_source_actor = stat_mod.source_id
	var mod_source_faction = stat_mod.source_faction
	if not conditions:
		return true
	
	# Check Faction Filters
	var faction_filters = conditions.get("HostFactionFilters", [])
	if not FilterHelper.check_faction_filter(mod_source_actor, mod_source_faction, faction_filters, actor):
		return false
			
	# Check Defender Tag Filters
	var host_tag_filters = conditions.get("HostTagFilters", [])
	for tag_filter in host_tag_filters:
		if not SourceTagChain.filters_accept_tags(tag_filter, actor.get_tags()):
			return false
			
	# Check Source Tag Filters
	var source_tag_filters = conditions.get("SourceTagFilters", [])
	for source_tag_filter in source_tag_filters:
		if not SourceTagChain.filters_accept_tags(source_tag_filter, attack_source_tag_chain.get_all_tags()):
			return false
	
	return true

static func _tranlate_damage_vfx_data(attacker_id:String, sub_event:AttackSubEvent, damage_event:DamageEvent, damage_data:Dictionary )->Dictionary:
	var damage_vfx_key = damage_data.get("DamageVfxKey", null)
	var damage_vfx_data = damage_data.get("DamageVfxData", {}).duplicate()
	if damage_event.final_damage < 0:
		damage_vfx_data['DamageTextType'] = FlashTextController.FlashTextType.Healing_Dmg
	elif sub_event.is_crit and not sub_event.is_blocked:
		damage_vfx_data['DamageTextType'] = FlashTextController.FlashTextType.Crit_Dmg
	elif sub_event.is_blocked and not sub_event.is_crit:
		damage_vfx_data['DamageTextType'] = FlashTextController.FlashTextType.Blocked_Dmg
	else:
		damage_vfx_data['DamageTextType'] = FlashTextController.FlashTextType.Normal_Dmg
	damage_vfx_data['SourceActorId'] = attacker_id
	damage_vfx_data['DamageNumber'] = 0 - damage_event.final_damage
	return {
		"DamageVfxKey": damage_data.get("DamageVfxKey", null),
		"DamageVfxData": damage_vfx_data
	}

## Get AttackEvent.AttackDirection between Attacker and Defender
static func get_relative_attack_direction(attacker_pos:MapPos, defender_pos:MapPos, awareness:int=0)->AttackDirection:
	if defender_pos == null:
		#TODO: Missiles from dead actors
		printerr("Defender posision not provided")
		return AttackDirection.Front
	if attacker_pos == null:
		#TODO: Missiles from dead actors
		printerr("Attcker posision not provided")
		return AttackDirection.Front
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
	
	var is_side = abs(front_back_change) < abs(right_left_change)
	var is_diaginal = abs(front_back_change) == abs(right_left_change)
	var is_forward = not is_side and front_back_change >= 0
	var is_back = not is_side and front_back_change <= 0
	if awareness <= -4:
		return AttackDirection.Back
	elif awareness == -3:
		if is_forward and not is_diaginal:
			return AttackDirection.Flank
		else:
			return AttackDirection.Back
	elif awareness == -2:
		if is_forward and not is_diaginal:
			return AttackDirection.Front
		elif front_back_change > 0:
			return AttackDirection.Flank
		else:
			return AttackDirection.Back
	elif awareness == -1:
		if is_forward and not is_diaginal:
			return AttackDirection.Front
		elif is_back:
			return AttackDirection.Back
		else:
			return AttackDirection.Flank
	elif awareness == 0:
		if is_forward:
			return AttackDirection.Front
		elif is_side:
			return AttackDirection.Flank
		else:
			return AttackDirection.Back
	elif awareness == 1:
		if is_forward:
			return AttackDirection.Front
		elif is_side or is_diaginal:
			return AttackDirection.Flank
		else:
			return AttackDirection.Back
	elif awareness == 2:
		if is_back and not is_diaginal:
			return AttackDirection.Back
		elif front_back_change < 0:
			return AttackDirection.Flank
		else:
			return AttackDirection.Front
	elif awareness == 3:
		if is_back and not is_diaginal:
			return AttackDirection.Flank
		else:
			return AttackDirection.Front
	else:
		return AttackDirection.Front
			
	
	#if abs(front_back_change) >= abs(right_left_change):
		#if front_back_change >= 0:
			#return AttackDirection.Front
		#else:
			#return AttackDirection.Back
	#else:
		#return AttackDirection.Flank













static func handle_colision(
	moving_actor:BaseActor, 
	blocking_actor:BaseActor,
	game_state:GameStateData,
	simulated:bool=false # Simulated collisions do not apply damage
)->CollisionEvent:
	
	printerr("\n%s crash into %s" % [moving_actor.details.display_name, blocking_actor.details.display_name])
	var attack_mods = {}
	var stat_mods = {}
	
	var damage_data = {
		"AtkPwrBase": 100, 
		"AtkPwrRange": 30, 
		"AtkPwrScale": 1, 
		"AtkStat": "Mass",
		"DamageType": "Crash",
		"DefenseType": "Armor",
		"DamageVfxKey": "Blunt_DamageEffect",
		"DamageVfxData":{
			"ShakeActor":false
		},
	}
	
	var source_tag_chain = SourceTagChain.new()\
	.append_source(SourceTagChain.SourceTypes.Actor, moving_actor)\
	.force_add_tag("Collision")
	
	var all_tags = source_tag_chain.get_all_tags()
	
	var all_unique_actors = [moving_actor, blocking_actor]
	var attack_posision_data = {}
	var attacker_pos = game_state.get_actor_pos(moving_actor)
	var defender_pos = game_state.get_actor_pos(blocking_actor)
	attack_posision_data[blocking_actor.Id] = {}
	attack_posision_data[blocking_actor.Id]['AttackDirection'] = get_relative_attack_direction(attacker_pos, defender_pos)
	attack_posision_data[blocking_actor.Id]['HasCover'] = false
		
	# Get Applicable Stat Mods
	for actor:BaseActor in all_unique_actors:
		var actor_attack_mods = actor.get_attack_mods()
		for actor_attack_mod_key in actor_attack_mods.keys():
			var attack_mod = actor_attack_mods[actor_attack_mod_key]
			# Check if mod applies to attack
			if _does_attack_mod_apply(attack_mod, moving_actor, [blocking_actor], source_tag_chain, attack_posision_data):
				var mod_id = attack_mod['AttackModId']
				attack_mods[mod_id] = attack_mod
				# Cache Stat Mods now to avoid another loop
				var sub_stat_mods = _get_stat_mods_from_attack_mod(attack_mod)
				for sub_stat_mod_key in sub_stat_mods.keys():
					stat_mods[sub_stat_mod_key] = sub_stat_mods[sub_stat_mod_key]
			
	
	# Apply Stat mods to appropiate Actors 
	for actor:BaseActor in all_unique_actors:
		for stat_mod_id in stat_mods.keys():
			var stat_mod = stat_mods[stat_mod_id]
			if _does_attack_stat_mod_apply_to_actor(stat_mod, actor, source_tag_chain):
				actor.stats.add_temp_stat_mod(stat_mod_id, stat_mod, false)
		actor.stats.apply_temp_stat_mods()
	
	var mover_mass = moving_actor.stats.get_stat(StatHelper.Mass)
	var blocker_mass = blocking_actor.stats.get_stat(StatHelper.Mass)
	
	# Mover wins if Mass is >= Blocker Mass
	var winner = moving_actor
	var loser = blocking_actor 
	if mover_mass < blocker_mass:
		winner = blocking_actor
		loser = moving_actor
		
	damage_data['AtkPwrScale'] = 1.0 - (maxf(minf(mover_mass, blocker_mass),1) / maxf(mover_mass, blocker_mass))
	
	var damage_event:DamageEvent = null
	if not simulated:
		# Get damage mods from AttackMods and passive mods from Attacker and Defender
		var damage_mods = {}
		for attack_mod in attack_mods.values():
			var sub_damage_mods = attack_mod.get("DamageMods", {})
			for sub_key in sub_damage_mods.keys():
				var sub_mod = sub_damage_mods[sub_key]
				# Damage mods already filtered inside of DamageHelper.roll_for_damage
				# if DamageHelper.does_damage_mod_apply(sub_mod, winner,  loser, damage_data, source_tag_chain):
				var mod_id = damage_mods.get("DamageModId", "NO_ID")
				damage_mods[mod_id] = sub_mod
		
		# Who is Attacker and Defender when Mover / Blocker doesn't match winner / loser
		
		damage_mods.merge(loser.get_damage_mods())
		damage_mods.merge(winner.get_damage_mods())
	
		# Calculate Damage
		damage_event = DamageHelper.roll_for_damage(damage_data, winner, loser, source_tag_chain, damage_mods)
		
		# Apply damage 
		loser.stats.apply_damage(damage_event.final_damage)
		damage_event.was_applied = true
		
		var damage_effect = damage_data.get("DamageVfxKey", "Blunt_DamageEffect")
		var damage_effect_data = damage_data.get("DamageVfxData", {})
		damage_effect_data['DamageTextType'] = FlashTextController.FlashTextType.DOT_Dmg
		damage_effect_data['SourceActorId'] = winner.Id
		damage_effect_data['DamageNumber'] = 0 - damage_event.final_damage
		VfxHelper.create_damage_effect(loser, damage_effect, damage_effect_data)
		
	# Clear Temp Stat Mods from Actors
	for actor:BaseActor in all_unique_actors:
		actor.stats.clear_temp_stat_mods()
	
	printerr("And %s won" % [winner.details.display_name])
	if damage_event:
		print(damage_event.dictialize_self())
	
	return CollisionEvent.new(moving_actor, blocking_actor, winner, damage_event, attack_mods)
