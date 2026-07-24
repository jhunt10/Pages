class_name SubEffect_CreateVfx
extends BaseSubEffect

func get_required_props()->Dictionary:
	return {}

func get_triggers(_effect:BaseEffect, _subeffect_data:Dictionary)->Array:
	return [BaseEffect.EffectTriggers.OnCreate]

func on_effect_trigger(effect:BaseEffect, subeffect_data:Dictionary, _trigger:BaseEffect.EffectTriggers, _game_state:GameStateData):
	var actor = effect.get_effected_actor()
	var vfx_key = subeffect_data.get("VfxKey")
	var vfx_data = subeffect_data.get("VfxData", {"CanStack":false})
	var vfx_node = VfxHelper.create_vfx_on_actor(actor, vfx_key, vfx_data)
	if vfx_node:
		subeffect_data['VfxId'] = vfx_node.id
	else:
		printerr("SubEffect_AilmentVfx.Failed to create VfxNode for Ailment: " + subeffect_data.get("AilmentKey"))

func on_delete(effect:BaseEffect, subeffect_data:Dictionary):
	var actor = effect.get_effected_actor()
	var vfx_key = subeffect_data.get("VfxKey")
	var actor_node = CombatRootControl.get_actor_node(actor.Id)
	if actor_node:
		actor_node.vfx_holder.remove_vfx(vfx_key)
