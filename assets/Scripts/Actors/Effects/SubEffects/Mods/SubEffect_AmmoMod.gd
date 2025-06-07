class_name SubEffect_AmmoMod
extends BaseSubEffect

func get_required_props()->Dictionary:
	return {
		
	}

## Returns an array of EffectTriggers on which to call this SubEffect
func get_triggers(_effect:BaseEffect, subeffect_data:Dictionary)->Array:
	return [BaseEffect.EffectTriggers.OnCreate]

func on_effect_trigger(effect:BaseEffect, _subeffect_data:Dictionary,
						_trigger:BaseEffect.EffectTriggers, _game_state:GameStateData):
	var effected_actor = effect.get_effected_actor()
	effected_actor.Que.dirty_ammo_mods()


func on_delete(effect:BaseEffect, _subeffect_data:Dictionary):
	var effected_actor = effect.get_effected_actor()
	effected_actor.Que.dirty_ammo_mods()
