class_name BaseSubEffect

enum SubEffectPropTypes {Triggers, StatModKey, DamageModKey, DamageKey, SubEffectKey, EnumVal, StringVal, IntVal}

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
	
func get_active_damage_mods(_effect:BaseEffect, _subeffect_data:Dictionary)->Array:
	return []

func on_delete(_effect:BaseEffect, _subeffect_data:Dictionary):
	pass

func on_effect_trigger(_effect:BaseEffect, _subeffect_data:Dictionary,
						_trigger:BaseEffect.EffectTriggers, _game_state:GameStateData):
	pass

func on_deal_damage(_effect:BaseEffect, _subeffect_data:Dictionary,
					_game_state:GameStateData, _value:int, _damage_type:String, _target:BaseActor):
	on_effect_trigger(_effect, _subeffect_data, BaseEffect.EffectTriggers.OnDamagDealt, _game_state )
	pass

func on_take_damage(_effect:BaseEffect, _subeffect_data:Dictionary,
					_game_state:GameStateData, _value:int, _damage_type:String, _source):
	on_effect_trigger(_effect, _subeffect_data, BaseEffect.EffectTriggers.OnDamageTaken, _game_state)
	pass

func on_move(_effect:BaseEffect, _subeffect_data:Dictionary,
			_game_state:GameStateData, _old_pos:MapPos, _new_pos:MapPos, _move_type:String, _moved_by:BaseActor):
	on_effect_trigger(_effect, _subeffect_data, BaseEffect.EffectTriggers.OnMove, _game_state)
	pass

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
