class_name BaseSubEffect

enum SubEffectPropTypes {Triggers, StatModKey, DamageModKey, SubEffectKey, EnumOptions, StringVal, IntVal}

# Returns a Dictionary of {Property Name, Property Type} for what properties this subeffect
# 	exspects to find in it's subeffect_data (Mostly for Effect Editor)
func get_required_props()->Dictionary: return {}
func get_enum_option_values()->Dictionary: return {}

func _init() -> void:
	pass

func get_required_triggers(_effect:BaseEffect, _subeffect_data:Dictionary)->Array:
	return []

func get_optional_triggers(_effect:BaseEffect, subeffect_data:Dictionary)->Array:
	var list = []
	if subeffect_data.has("OptionalTriggers"):
		for trig_val in subeffect_data['OptionalTriggers']:
			if trig_val is String:
				if BaseEffect.EffectTriggers.has(trig_val):
					list.append(BaseEffect.EffectTriggers.get(trig_val))
			else:
				list.append(trig_val)
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
	pass

func on_take_damage(_effect:BaseEffect, _subeffect_data:Dictionary,
					_game_state:GameStateData, _value:int, _damage_type:String, _source):
	pass

func on_move(_effect:BaseEffect, _subeffect_data:Dictionary,
			_game_state:GameStateData, _old_pos:MapPos, _new_pos:MapPos, _move_type:String, _moved_by:BaseActor):
	pass

func on_use_item(_effect:BaseEffect, _subeffect_data:Dictionary,
				_game_state:GameStateData, _item, _target):
	pass
