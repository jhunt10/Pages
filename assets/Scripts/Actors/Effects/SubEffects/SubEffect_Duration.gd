class_name SubEffect_Duration
extends BaseSubEffect

enum DurationTypes {
	TurnStart, TurnEnd, 
	RoundStart, RoundEnd,
	ActionStart, ActionEnd,  
	GapStart, GapEnd,
	Trigger}

func get_required_props()->Dictionary:
	return {
		"DurationType": BaseSubEffect.SubEffectPropTypes.EnumVal,
		"MaxDuration": BaseSubEffect.SubEffectPropTypes.IntVal,
		"DurationValue": BaseSubEffect.SubEffectPropTypes.IntVal
	}
	
func get_prop_enum_values(key:String)->Array:
	if key ==  "DurationType": 
		return DurationTypes.keys()
	return []


func merge_new_duplicate_sub_effect_data(parent_effect:BaseEffect, own_sub_effect_data:Dictionary, dup_sub_effect_data:Dictionary):
	var base_duration = dup_sub_effect_data.get('DurationValue', -1)
	if base_duration < 0:
		base_duration = parent_effect.get_load_val("Duration", -1)
	parent_effect._duration_counter = max(parent_effect._duration_counter, base_duration)
	pass

func get_triggers(effect:BaseEffect, subeffect_data:Dictionary)->Array:
	var list = super(effect, subeffect_data)
	
	if !list.has(BaseEffect.EffectTriggers.OnCreate):
		list.append(BaseEffect.EffectTriggers.OnCreate)
	var duration_type = DurationTypes.get(subeffect_data['DurationType'])
	if duration_type == DurationTypes.TurnStart:
		list.append(BaseEffect.EffectTriggers.OnTurnStart)
	if true or duration_type == DurationTypes.TurnEnd:
		list.append(BaseEffect.EffectTriggers.OnTurnEnd)
		
	if duration_type == DurationTypes.RoundStart:
		list.append(BaseEffect.EffectTriggers.OnRoundStart)
	if true or duration_type == DurationTypes.RoundEnd:
		list.append(BaseEffect.EffectTriggers.OnRoundEnd)
		
	if duration_type == DurationTypes.ActionStart:
		list.append(BaseEffect.EffectTriggers.OnActionStart)
	if  duration_type == DurationTypes.ActionEnd:
		list.append(BaseEffect.EffectTriggers.OnActionEnd)
		
	if duration_type == DurationTypes.GapStart:
		list.append(BaseEffect.EffectTriggers.OnGapTurnStart)
	if duration_type == DurationTypes.GapEnd:
		list.append(BaseEffect.EffectTriggers.OnGapTurnEnd)
	return list
	

func on_effect_trigger(effect:BaseEffect, subeffect_data:Dictionary, trigger:BaseEffect.EffectTriggers, _game_state:GameStateData):
	if trigger == BaseEffect.EffectTriggers.OnCreate:
		var duration = subeffect_data.get('DurationValue', -1)
		if duration < 0:
			duration = effect.get_load_val("Duration", -1)
		effect._duration_counter = duration
		return
	#printerr("Durration For: %s Trigger: %s Value: %s" % [effect.details.display_name, BaseEffect.EffectTriggers.keys()[trigger], effect._duration_counter])
	var duration_type = DurationTypes.get(subeffect_data['DurationType'])
	if duration_type == DurationTypes.TurnStart and trigger == BaseEffect.EffectTriggers.OnTurnStart:
		effect._duration_counter -= 1
	if duration_type == DurationTypes.TurnEnd and trigger == BaseEffect.EffectTriggers.OnTurnEnd:
		effect._duration_counter -= 1
		
	if duration_type == DurationTypes.RoundStart and trigger == BaseEffect.EffectTriggers.OnRoundStart:
		effect._duration_counter -= 1
	if duration_type == DurationTypes.RoundEnd and trigger == BaseEffect.EffectTriggers.OnRoundEnd:
		effect._duration_counter -= 1
		
	if duration_type == DurationTypes.ActionStart and trigger == BaseEffect.EffectTriggers.OnActionStart:
		effect._duration_counter -= 1
	if duration_type == DurationTypes.ActionEnd and trigger == BaseEffect.EffectTriggers.OnActionEnd:
		effect._duration_counter -= 1
		
	if duration_type == DurationTypes.GapStart and trigger == BaseEffect.EffectTriggers.OnGapTurnStart:
		effect._duration_counter -= 1
	if duration_type == DurationTypes.GapEnd and trigger == BaseEffect.EffectTriggers.OnGapTurnEnd:
		effect._duration_counter -= 1
