class_name SubEffect_ApplyStatMod
extends BaseSubEffect

func get_required_props()->Dictionary:
	return {"StatModKey": BaseSubEffect.SubEffectPropTypes.StatModKey}

var _stat_mod:BaseStatMod

func get_required_triggers()->Array:
	return [BaseEffect.EffectTriggers.OnCreate]

func _init(effect:BaseEffect, subeffect_data:Dictionary) -> void:
	super(effect, subeffect_data)
	var stat_mod_key = data['StatModKey']
	var mod = parent_effect.StatModDatas.get(stat_mod_key, null)
	if not mod:
		printerr("SubEffect_ApplyStatMod.get_active_stat_mods: Failed to find mod with key '%s'." % [stat_mod_key])
		return
	_stat_mod = BaseStatMod.new(effect.Id, effect.StatModDatas[stat_mod_key])

func get_active_stat_mods()->Array:
	return [_stat_mod]

func on_effect_trigger(trigger:BaseEffect.EffectTriggers, _game_state:GameStateData):
	if trigger == BaseEffect.EffectTriggers.OnCreate:
		parent_effect._actor.stats.dirty_stats()

func on_delete():
	parent_effect._actor.stats.dirty_stats()
