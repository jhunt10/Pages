class_name BaseSubEffect

static func get_required_tags()->Array:
	return []

static func get_optional_triggers(effect:BaseEffect, sub_effect_data:Dictionary)->Array:
	var list = []
	if sub_effect_data.has("OptionalTriggers"):
		for trig_str in sub_effect_data['OptionalTriggers']:
			if BaseEffect.EffectTriggers.has(trig_str):
				list.append(BaseEffect.EffectTriggers.get(trig_str))
	return list

static func do_effect(trigger:BaseEffect.EffectTriggers, effect:BaseEffect, sub_effect_data:Dictionary, game_state:GameStateData):
	pass

func on_deal_damage(value:int, damage_type:String, target:BaseActor):
	pass

func on_take_damage(value:int, damage_type:String, source):
	pass

func on_move(_old_pos:MapPos, _new_pos:MapPos, _move_type:String, _moved_by:BaseActor):
	pass
