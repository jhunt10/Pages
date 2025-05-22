class_name BaseSubEffect

enum SubEffectPropTypes {Triggers, StatModKey, DamageModKey, DamageKey, SubEffectKey, EnumVal, StringVal, IntVal, DictVal, BoolVal}

# Returns a Dictionary of {Property Name, Property Type} for what properties this subeffect
# 	exspects to find in it's subeffect_data (Mostly for Effect Editor)
func get_required_props()->Dictionary: return {}
func get_prop_enum_values(key:String)->Array: return []

func _init() -> void:
	pass

## Returns an array of EffectTriggers on which to call this SubEffect
func get_triggers(_effect:BaseEffect, subeffect_data:Dictionary)->Array:
	var optional_triggers = subeffect_data.get("OptionalTriggers")
	if !optional_triggers: return []
	var list = []
	for key in optional_triggers:
		list.append(BaseEffect.EffectTriggers.get(key))
	return list

func get_active_stat_mods(_effect:BaseEffect, _subeffect_data:Dictionary)->Array:
	return []
	
func get_active_damage_mods(_effect:BaseEffect, _subeffect_data:Dictionary)->Dictionary:
	var mods = _subeffect_data.get("DamageMods", {}).duplicate(true)
	return mods

func get_active_attack_mods(_effect:BaseEffect, _subeffect_data:Dictionary)->Dictionary:
	var mods = _subeffect_data.get("AttackMods", {}).duplicate(true)
	return mods

func on_delete(_effect:BaseEffect, _subeffect_data:Dictionary):
	pass

func on_effect_trigger(_effect:BaseEffect, _subeffect_data:Dictionary,
						_trigger:BaseEffect.EffectTriggers, _game_state:GameStateData):
	pass

func on_damage_dealt(_effect:BaseEffect, _subeffect_data:Dictionary,
					_game_state:GameStateData, _damage_event:DamageEvent):
	on_effect_trigger(_effect, _subeffect_data, BaseEffect.EffectTriggers.OnDamagDealt, _game_state )
	pass

func on_damage_taken(_effect:BaseEffect, _subeffect_data:Dictionary,
					_game_state:GameStateData, _damage_event:DamageEvent):
	on_effect_trigger(_effect, _subeffect_data, BaseEffect.EffectTriggers.OnDamageTaken, _game_state)
	pass



# Attack/Defend function to make logic more distinct

func on_attacking_pre_attack_roll(_effect:BaseEffect, _subeffect_data:Dictionary, _game_state:GameStateData, _attack_event:AttackEvent):
	on_effect_trigger(_effect, _subeffect_data, BaseEffect.EffectTriggers.OnAttacking_PreAttackRoll, _game_state)
	pass

func on_attacking_post_attack_roll(_effect:BaseEffect, _subeffect_data:Dictionary, _game_state:GameStateData, _attack_event:AttackEvent):
	on_effect_trigger(_effect, _subeffect_data, BaseEffect.EffectTriggers.OnAttacking_PreAttackRoll, _game_state)
	pass

func on_attacking_post_effect_roll(_effect:BaseEffect, _subeffect_data:Dictionary, _game_state:GameStateData, _attack_event:AttackEvent):
	on_effect_trigger(_effect, _subeffect_data, BaseEffect.EffectTriggers.OnAttacking_PreAttackRoll, _game_state)
	pass

func on_attacking_post_damage_roll(_effect:BaseEffect, _subeffect_data:Dictionary, _game_state:GameStateData, _attack_event:AttackEvent):
	on_effect_trigger(_effect, _subeffect_data, BaseEffect.EffectTriggers.OnAttacking_PreAttackRoll, _game_state)
	pass

func on_attacking_after_attack(_effect:BaseEffect, _subeffect_data:Dictionary, _game_state:GameStateData, _attack_event:AttackEvent):
	on_effect_trigger(_effect, _subeffect_data, BaseEffect.EffectTriggers.OnAttacking_PreAttackRoll, _game_state)
	pass

func on_defending_pre_attack_roll(_effect:BaseEffect, _subeffect_data:Dictionary, _game_state:GameStateData, _attack_event:AttackEvent):
	on_effect_trigger(_effect, _subeffect_data, BaseEffect.EffectTriggers.OnAttacking_PreAttackRoll, _game_state)
	pass

func on_defending_post_attack_roll(_effect:BaseEffect, _subeffect_data:Dictionary, _game_state:GameStateData, _attack_event:AttackEvent):
	on_effect_trigger(_effect, _subeffect_data, BaseEffect.EffectTriggers.OnAttacking_PreAttackRoll, _game_state)
	pass

func on_defending_post_effect_roll(_effect:BaseEffect, _subeffect_data:Dictionary, _game_state:GameStateData, _attack_event:AttackEvent):
	on_effect_trigger(_effect, _subeffect_data, BaseEffect.EffectTriggers.OnAttacking_PreAttackRoll, _game_state)
	pass

func on_defending_post_damage_roll(_effect:BaseEffect, _subeffect_data:Dictionary, _game_state:GameStateData, _attack_event:AttackEvent):
	on_effect_trigger(_effect, _subeffect_data, BaseEffect.EffectTriggers.OnAttacking_PreAttackRoll, _game_state)
	pass

func on_defending_after_attack(_effect:BaseEffect, _subeffect_data:Dictionary, _game_state:GameStateData, _attack_event:AttackEvent):
	on_effect_trigger(_effect, _subeffect_data, BaseEffect.EffectTriggers.OnAttacking_PreAttackRoll, _game_state)
	pass





func before_move(_effect:BaseEffect, _subeffect_data:Dictionary,
			_game_state:GameStateData, _old_pos:MapPos, _new_pos:MapPos, _move_type:String, _moved_by:BaseActor):
	on_effect_trigger(_effect, _subeffect_data, BaseEffect.EffectTriggers.PostMove, _game_state)
	pass

func after_move(_effect:BaseEffect, _subeffect_data:Dictionary,
			_game_state:GameStateData, _old_pos:MapPos, _new_pos:MapPos, _move_type:String, _moved_by:BaseActor):
	on_effect_trigger(_effect, _subeffect_data, BaseEffect.EffectTriggers.PostMove, _game_state)
	pass

func on_collision(_effect:BaseEffect, _subeffect_data:Dictionary, collision_event:CollisionEvent, _game_state:GameStateData):
	on_effect_trigger(_effect, _subeffect_data, BaseEffect.EffectTriggers.OnCollision, _game_state)

func on_use_item(_effect:BaseEffect, _subeffect_data:Dictionary,
				_game_state:GameStateData, _item, _target):
	on_effect_trigger(_effect, _subeffect_data, BaseEffect.EffectTriggers.OnUseItem, _game_state)
	pass

## Convert an array of String or int to an array of EffectTriggers 
func _array_to_trigger_list(arr:Array)->Array:
	var out_list = []
	for trig_val in arr:
		if trig_val is String:
			if BaseEffect.EffectTriggers.has(trig_val):
				out_list.append(BaseEffect.EffectTriggers.get(trig_val))
		elif trig_val is int:
			out_list.append(trig_val)
		else:
			printerr("BaseSubEffect._array_to_trigger_list: Unknown EffectTrigger value '%s'." % [trig_val])
	return out_list

func merge_new_duplicate_sub_effect_data(parent_effect:BaseEffect, own_sub_effect_data:Dictionary, dup_sub_effect_data:Dictionary):
	pass
