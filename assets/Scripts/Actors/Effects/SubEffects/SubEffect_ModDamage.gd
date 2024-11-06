class_name SubEffect_ModDamage
extends BaseSubEffect

func get_required_props()->Dictionary:
	return {"DamageModKey": BaseSubEffect.SubEffectPropTypes.DamageModKey}

var _stat_mod:BaseStatMod

func get_triggers(_effect:BaseEffect, _subeffect_data:Dictionary)->Array:
	var list = super(_effect, _subeffect_data)
	if !list.has(BaseEffect.EffectTriggers.OnCreate):
		list.append(BaseEffect.EffectTriggers.OnCreate)
	return list

func get_active_stat_mods(effect:BaseEffect, subeffect_data:Dictionary)->Array:
	var damage_mod_key = subeffect_data['DamageModKey']
	var mod = effect.DamageModDatas.get(damage_mod_key, null)
	return []#[BaseDamageMod.new(effect.Id, effect.DamageModDatas[stat_mod_key])]

func on_effect_trigger(effect:BaseEffect, _subeffect_data:Dictionary, trigger:BaseEffect.EffectTriggers, _game_state:GameStateData):
	if trigger == BaseEffect.EffectTriggers.OnCreate:
		effect.get_effected_actor().stats.dirty_stats()

func on_delete(effect:BaseEffect, _subeffect_data:Dictionary):
	effect.get_effected_actor().stats.dirty_stats()
