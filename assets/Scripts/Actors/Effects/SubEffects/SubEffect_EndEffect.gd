class_name SubEffect_EndEffect
extends BaseSubEffect

func get_required_props()->Dictionary:
	return {}

func get_triggers(_effect:BaseEffect, _subeffect_data:Dictionary)->Array:
	return super(_effect, _subeffect_data)

## Force duration to end after this trigger
func on_effect_trigger(effect:BaseEffect, _subeffect_data:Dictionary, trigger:BaseEffect.EffectTriggers, _game_state:GameStateData):
	effect.duration_trigger = trigger
	effect._duration_counter = 1
