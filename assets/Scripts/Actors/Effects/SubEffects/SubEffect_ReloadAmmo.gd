class_name SubEffect_RefillAmmo
extends BaseSubEffect

enum RegenTypes {Turn, Round, Trigger}

func get_required_props()->Dictionary:
	return {}

## Returns Tags that are automatically added to the parent Effect's Tags
func get_effect_tags(_subeffect_data:Dictionary, _effect_data:Dictionary, _parent_effect:BaseEffect=null)->Array:
	return ["Reload"]

func get_triggers(effect:BaseEffect, subeffect_data:Dictionary)->Array:
	var list = super(effect, subeffect_data)
	var optional_triggers_arr = subeffect_data['Triggers']
	for opt_trig in _array_to_trigger_list(optional_triggers_arr):
		list.append(opt_trig)
	return list

func on_effect_trigger(effect:BaseEffect, subeffect_data:Dictionary, trigger:BaseEffect.EffectTriggers, _game_state:GameStateData):
	var actor:BaseActor = effect.get_effected_actor()
	var action_key = subeffect_data.get("ActionKey", null)
	if not action_key:
		printerr("Refill Ammo: No Action Key found.")
		return
	actor.Que.fill_page_ammo(action_key)
