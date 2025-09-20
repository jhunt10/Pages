class_name SubEffect_Freeze
extends BaseSubEffect

func get_required_props()->Dictionary:
	return {}

func get_triggers(_effect:BaseEffect, subeffect_data:Dictionary)->Array:
	return [BaseEffect.EffectTriggers.OnCreate]

func on_effect_trigger(effect:BaseEffect, subeffect_data:Dictionary, trigger:BaseEffect.EffectTriggers, game_state:GameStateData):
	var actor = effect.get_effected_actor()
	var actor_node = CombatRootControl.get_actor_node(actor.Id)
	actor.Que.fail_turn()
	#actor_node.fail_movement()
	actor_node.cancel_weapon_animations()
	#actor_node.freeze_animations()

func on_delete(effect:BaseEffect, subeffect_data:Dictionary):
	var actor = effect.get_effected_actor()
	var actor_node = CombatRootControl.get_actor_node(actor.Id)
	#actor_node.unfreeze_animations()
