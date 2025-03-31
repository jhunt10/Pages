class_name EffectHelper

# Types of effects that have special logic 
#  for both number of effects on one actor
#  and number of other actors one can apply to
enum LimitedEffectTypes {None, Blessing, Curse, Aura, WarCry, Dance, Song}

static var is_creating_effect:bool = false

static func create_effect( 
		target:BaseActor, 
		source, 
		effect_key:String, 
		effect_data:Dictionary, 
		game_state:GameStateData=null, 
		force_id:String='', 
		suppress_signals:bool = false
	)->BaseEffect:
	is_creating_effect = true
	var source_actor:BaseActor = null
	if source is BaseActor:
		source_actor = source
		effect_data['AppliedPotency'] = source_actor.stats.get_stat(StatHelper.Potency, 1)
		
	
	var effect_def = EffectLibrary.get_merged_effect_def(effect_key, effect_data)
	var effect_potency = effect_def.get("AppliedPotency", 1)
	
	# Check and handle Limited Effect logic
	var limited_effect_type_str = effect_def.get("LimitedEffectType", "None")
	var limited_effect_type = LimitedEffectTypes.get(limited_effect_type_str)
	if limited_effect_type:
		if not source is BaseActor:
			printerr("EffectHelper: Failed to make effect '%s'. Limited Effect of type '%s' has non-Actor Source." % [effect_key, limited_effect_type_str])
			is_creating_effect = false
			return null
		# If same effect from same soure, ignore rest of logic and return existing 
		var existing_same_effects = target.effects.get_effects_with_key(effect_key)
		if existing_same_effects.size() > 0:
			var existing_same:BaseEffect = existing_same_effects[0]
			if existing_same.get_source_actor() == source_actor:
				existing_same.merge_new_duplicate_effect_data(source, effect_def)
				is_creating_effect = false
				return existing_same
		# Check Per Actor Limit: how many Effects one Actor can have
		var source_per_actor_limit = source_actor.effects.get_per_actor_limit_for_limited_effect(limited_effect_type)
		var target_per_actor_limit = target.effects.get_on_self_limit_for_limited_effect(limited_effect_type)
		var per_actor_limit = max(source_per_actor_limit, target_per_actor_limit)
		var existing_effects_on_target = target.effects.list_holding_limited_effect(limited_effect_type)
		# Over the limit for number of effects on one actor
		if existing_effects_on_target.size() > per_actor_limit - 1:
			existing_effects_on_target.reverse()
			var lowest_potency_val = effect_potency
			var lowest_potency_effect = null
			for limited_effect:BaseEffect in existing_effects_on_target:
				if limited_effect.applied_potency < lowest_potency_val:
					lowest_potency_val = limited_effect.applied_potency
					lowest_potency_effect = limited_effect
			if lowest_potency_effect != null:
				target.effects.remove_effect(lowest_potency_effect)
			else:
				# Can not replace any existing limited effects
				is_creating_effect = false
				return null
		
		# Check Total Count Limit: how many instances of Effect that Source has applied
		var max_count_limit = source_actor.effects.get_count_limit_for_limited_effect(limited_effect_type)
		var current_effect_count = source_actor.effects.get_count_of_hosted_limited_effect(limited_effect_type)
		if max_count_limit == 0:
			printerr("EffectHelper: Failed to make effect '%s'. ActorCountLimit for Limited Effect of type '%s' is Zero for Source Actor '%s'." % [effect_key, limited_effect_type_str, source.Id])
			is_creating_effect = false
			return null
		# Over the limit for number of hoested effects 
		if current_effect_count > max_count_limit - 1:
			var rm_count_limit_effect_id = source_actor.effects.get_oldest_hosted_limited_effect_id(limited_effect_type)
			if rm_count_limit_effect_id == null:
				printerr("EffectHelper: Found null for oldest Limited Effect Id. Shouldn't Happen." )
			else:
				var oldest_effect = EffectLibrary.get_effect(rm_count_limit_effect_id)
				var oldest_actor = oldest_effect.get_effected_actor()
				oldest_actor.effects.remove_effect(oldest_effect)
		
		
		
	
	var effect = target.effects.add_effect(source, effect_key, effect_def, game_state, force_id, suppress_signals)
	
	
	is_creating_effect = false
	return effect
