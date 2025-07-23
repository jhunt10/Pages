class_name SubEffect_AilmentVfx
extends BaseSubEffect

func get_required_props()->Dictionary:
	return {}

func get_triggers(_effect:BaseEffect, subeffect_data:Dictionary)->Array:
	return [BaseEffect.EffectTriggers.OnCreate]

func on_effect_trigger(effect:BaseEffect, subeffect_data:Dictionary, trigger:BaseEffect.EffectTriggers, game_state:GameStateData):
	var actor = effect.get_effected_actor()
	var actor_node = CombatRootControl.get_actor_node(actor.Id)
	var vfx_node = VfxHelper.create_ailment_vfx_node(subeffect_data.get("AilmentKey"), actor)
	if vfx_node:
		subeffect_data['VfxId'] = vfx_node.id
	else:
		printerr("SubEffect_AilmentVfx.Failed to create VfxNode for Ailment: " + subeffect_data.get("AilmentKey"))

func on_delete(effect:BaseEffect, subeffect_data:Dictionary):
	var actor = effect.get_effected_actor()
	var ailment_key = subeffect_data.get("AilmentKey")
	var vfx_key = "Ailment" + ailment_key + "Vfx"
	
	var actor_node = CombatRootControl.get_actor_node(actor.Id)
	if actor_node:
		actor_node.vfx_holder.remove_vfx(vfx_key)
