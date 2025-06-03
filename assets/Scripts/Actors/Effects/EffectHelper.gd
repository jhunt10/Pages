class_name EffectHelper

# Types of effects that have special logic 
#  for both number of effects on one actor
#  and number of other actors one can apply to
enum LimitedEffectTypes {None, Blessing, Curse, Aura, WarCry, Dance, Song}

static var is_creating_effect:bool = false

static func create_effect( 
		actor:BaseActor, 
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
	
	var effect_immunities = actor.get_effect_immunity()
	if effect_immunities.has(effect_key):
		printerr("EffectHelper.create_effect: Attempted to apply '%s' to '%s' who is immune.")
		is_creating_effect = false
		return null
	
	var effect_def = EffectLibrary.get_merged_effect_def(effect_key, effect_data)
	var effect_details = effect_def.get("EffectDetails", {})
	var effect_potency = effect_def.get("AppliedPotency", 1)
	
	# Build Id
	if force_id == '':
		if effect_details.get("CanHaveMultiple", false):
			force_id = effect_key + str(ResourceUID.create_id()) + ":" + actor.Id
		else:
			force_id = effect_key + ":" + actor.Id
	
	# Check if effect exists
	var existing = actor.effects.get_effect(force_id)
	if existing:
		existing.merge_duplicate_effect(source, effect_def)
		is_creating_effect = false
		return existing
	
	
	# Check and handle Limited Effect logic
	var limited_effect_type_str = effect_details.get("LimitedEffectType", "None")
	var limited_effect_type = LimitedEffectTypes.get(limited_effect_type_str)
	var limited_effect_to_remove:BaseEffect = null
	if limited_effect_type:
		if not source is BaseActor:
			printerr("EffectHelper: Failed to make effect '%s'. Limited Effect of type '%s' has non-Actor Source." % [effect_key, limited_effect_type_str])
			is_creating_effect = false
			return null
		# If same effect from same soure, ignore rest of logic and return existing 
		var existing_same_effects = actor.effects.get_effects_with_key(effect_key)
		if existing_same_effects.size() > 0:
			var existing_same:BaseEffect = existing_same_effects[0]
			if existing_same.get_source_actor() == source_actor:
				existing_same.merge_new_duplicate_effect_data(source, effect_def)
				is_creating_effect = false
				return existing_same
		# Check Per Actor Limit: how many Effects one Actor can have
		var source_per_actor_limit = source_actor.effects.get_per_actor_limit_for_limited_effect(limited_effect_type)
		var actor_per_actor_limit = actor.effects.get_on_self_limit_for_limited_effect(limited_effect_type)
		var per_actor_limit = max(source_per_actor_limit, actor_per_actor_limit)
		var existing_effects_on_actor = actor.effects.list_holding_limited_effect(limited_effect_type)
		# Over the limit for number of effects on one actor
		if existing_effects_on_actor.size() > per_actor_limit - 1:
			existing_effects_on_actor.reverse()
			var lowest_potency_val = effect_potency
			var lowest_potency_effect = null
			for limited_effect:BaseEffect in existing_effects_on_actor:
				if limited_effect.applied_potency < lowest_potency_val:
					lowest_potency_val = limited_effect.applied_potency
					lowest_potency_effect = limited_effect
			if lowest_potency_effect != null:
				limited_effect_to_remove = lowest_potency_effect
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
		if limited_effect_to_remove == null and current_effect_count > max_count_limit - 1:
			var rm_count_limit_effect_id = source_actor.effects.get_oldest_hosted_limited_effect_id(limited_effect_type)
			if rm_count_limit_effect_id == null:
				printerr("EffectHelper: Found null for oldest Limited Effect Id. Shouldn't Happen." )
			else:
				var oldest_effect = EffectLibrary.get_effect(rm_count_limit_effect_id)
				var oldest_actor = oldest_effect.get_effected_actor()
				limited_effect_to_remove = oldest_effect
	
	var effect = EffectLibrary._create_effect(source, actor, effect_key, effect_data, force_id, game_state, suppress_signals)
	if effect == null:
		return null
	
	var meta_data = {}
	actor.effects.trigger_new_effect_to_be_added(game_state, effect, meta_data)
	# Check if effect as negated
	if meta_data.get("WasNegated", false):
		EffectLibrary.Instance.erase_object(effect.Id)
		is_creating_effect = false
		return null
	
	actor.effects.__add_new_effect(effect, suppress_signals)
	
	if effect.get_limited_effect_type() != EffectHelper.LimitedEffectTypes.None:
		if source is BaseActor:
			source.effects.host_limited_effect(effect)
		
		
	effect.on_created(game_state)
	if effect.is_instant():
		actor.remove_effect(effect, suppress_signals)
	
	is_creating_effect = false
	return effect
