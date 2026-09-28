class_name SubEffect_AmmoMod
extends BaseSubEffect

func get_required_props()->Dictionary:
	return {
		
	}

## Returns an array of EffectTriggers on which to call this SubEffect
func get_triggers(_effect:BaseEffect, _subeffect_data:Dictionary)->Array:
	return [BaseEffect.EffectTriggers.OnCreate]

## Returns Tags that are automatically added to the parent Effect's Tags
func get_effect_tags(_subeffect_data:Dictionary, _effect_data:Dictionary, _parent_effect:BaseEffect=null)->Array:
	return ["AmmoMod"]
