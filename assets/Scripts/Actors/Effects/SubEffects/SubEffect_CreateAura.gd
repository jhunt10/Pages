class_name SubEffect_CreateAura
extends BaseSubEffect

func get_required_props()->Dictionary:
	return {
		
	}

func get_triggers(_effect:BaseEffect, _subeffect_data:Dictionary)->Array:
	return [BaseEffect.EffectTriggers.OnCreate]

func on_delete(effect:BaseEffect, _subeffect_data:Dictionary):
	var zone = CombatRootControl.Instance.get_zone(effect._cached_data.get("AuraZoneId", ""))
	if !zone:
		printerr("Effect '%s' Lost Aura Zone!")
		return
	zone._on_duration_end()
	

func on_effect_trigger(effect:BaseEffect, subeffect_data:Dictionary, trigger:BaseEffect.EffectTriggers, game_state:GameStateData):
	var source_actor = effect.get_source_actor()
	var effected_actor = effect.get_effected_actor()
	var zone_data_key = subeffect_data.get("ZoneDataKey")
	var zone_data = effect.get_zone_data(zone_data_key)
	if not zone_data:
		printerr("SubAct_CreateZone: Failed to find Zone Data with key '%s'." % [zone_data_key])
		return BaseSubAction.Failed
	
	var area_effect:AreaMatrix = null
	var aura_size = 1
	if aura_size == 1:
		area_effect = AreaMatrix.new([[-1,-1],[0,-1],[1,-1],[-1,0],[1,0],[-1,1],[0,1],[1,1]])
	
		
	var inzone_effect_data_key = zone_data.get("InZoneEffectDataKey")
	if inzone_effect_data_key:
		var inzone_effect_data = effect.get_nested_effect_data(inzone_effect_data_key)
		zone_data['InZoneEffectData'] = inzone_effect_data
	var source_chain = SourceTagChain.new()\
		.append_source(SourceTagChain.SourceTypes.Actor, effect.get_source_actor())\
		.append_source(SourceTagChain.SourceTypes.Effect, effect)
	
	var damage_data_key = effect.get("DamageKey")
	if damage_data_key:
		#TODO: If actor changes weapons, damage will not be updated
		zone_data['DamageData'] =  effect.get_damage_data(damage_data_key, source_actor)
	
	zone_data['LoadPath'] = effect.get_load_path()
	zone_data['AuraActorId'] = effected_actor.Id
	var zone_script_path = zone_data.get("ZoneScript")
	if !zone_script_path:
		printerr("SubAct_CreateZone: No Zone Script provied.")
		return BaseSubAction.Failed
	
	var target_spot = game_state.get_actor_pos(effected_actor)
		
	var zone_script = load(zone_script_path)
	var zone:BaseZone = zone_script.new(source_chain, zone_data, target_spot, area_effect)
	if not zone.is_active:
		printerr("SubAct_CreateZone: Zone failed to 'new'.")
		return BaseSubAction.Failed
		
	CombatRootControl.Instance.add_zone(zone)
	effect._cached_data['AuraZoneId'] = zone.Id
	return BaseSubAction.Success
