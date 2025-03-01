class_name SubEffect_AilmentVfx
extends BaseSubEffect

func get_required_props()->Dictionary:
	return {}

func get_triggers(_effect:BaseEffect, subeffect_data:Dictionary)->Array:
	return [BaseEffect.EffectTriggers.OnCreate]

func on_effect_trigger(effect:BaseEffect, subeffect_data:Dictionary, trigger:BaseEffect.EffectTriggers, game_state:GameStateData):
	var actor = effect.get_effected_actor()
	var actor_node = CombatRootControl.get_actor_node(actor.Id)
	var vfx_node = MainRootNode.vfx_libray.create_ailment_vfx_node(subeffect_data.get("AilmentKey"), actor)
	subeffect_data['VfxNodePath'] = actor_node.get_path_to(vfx_node)

func on_delete(effect:BaseEffect, subeffect_data:Dictionary):
	var actor = effect.get_effected_actor()
	var vfx_path = subeffect_data.get('VfxNodePath', null)
	if not vfx_path:
		return
	var actor_node = CombatRootControl.get_actor_node(actor.Id)
	var vfx_node = actor_node.get_node(vfx_path)
	if vfx_node and is_instance_valid(vfx_node):
		vfx_node.queue_free()
