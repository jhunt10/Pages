class_name BaseSubEffect

enum SubEffectPropTypes {Triggers, StatModKey, DamageModKey, SubEffectKey, StringVal, IntVal}

# Returns a Dictionary of {Property Name, Property Type} for what properties this subeffect
# 	exspects to find in it's subeffect_data (Mostly for Effect Editor)
func get_required_props()->Dictionary:
	return {}

var parent_effect:BaseEffect
var data:Dictionary

func _init(effect:BaseEffect, subeffect_data:Dictionary) -> void:
	parent_effect = effect
	data = subeffect_data.duplicate()

func get_required_triggers()->Array:
	return []

func get_optional_triggers()->Array:
	var list = []
	if data.has("OptionalTriggers"):
		for trig_str in data['OptionalTriggers']:
			if BaseEffect.EffectTriggers.has(trig_str):
				list.append(BaseEffect.EffectTriggers.get(trig_str))
	return list

func get_active_stat_mods()->Array:
	return []
	
func get_active_damage_mods()->Array:
	return []

func on_delete():
	pass

func on_effect_trigger(_trigger:BaseEffect.EffectTriggers, _game_state:GameStateData):
	pass

func on_deal_damage(_game_state:GameStateData, _value:int, _damage_type:String, _target:BaseActor):
	pass

func on_take_damage(_game_state:GameStateData, _value:int, _damage_type:String, _source):
	pass

func on_move(_game_state:GameStateData, _old_pos:MapPos, _new_pos:MapPos, _move_type:String, _moved_by:BaseActor):
	pass

func on_use_item(_game_state:GameStateData, _item, _target):
	pass
