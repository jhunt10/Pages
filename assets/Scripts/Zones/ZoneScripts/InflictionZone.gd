#class_name InflictionZone
#extends BaseZone
#
## Attempts to apply an Effect to all Actors inside the Zone at End of Turn 
## Use Attack Zone with no damage instead
#
#var _actor_ids_to_effect_ids:Dictionary = {}
#
#
#func _init(source:SourceTagChain, data:Dictionary, center:MapPos, area:AreaMatrix) -> void:
	#super(source, data, center, area)
	#var effect_data = _data.get("EffectData", {})
	#var effect_key = effect_data.get("EffectKey")
	#if not effect_key:
		#printerr("InflictionZone: Created without Effect Key")
		#is_active = false
		#return
	#CombatRootControl.Instance.QueController.end_of_turn_with_state.connect(_on_turn_end)
#
#func _on_duration_end():
	#CombatRootControl.Instance.QueController.end_of_turn_with_state.disconnect(_on_turn_end)
	#super()
#
#func _inflict_effect(actor:BaseActor, game_state:GameStateData):
	#var effect_data = _data.get("InZoneEffectData", {})
	#var effect_key = effect_data.get("EffectKey")
	#var effect = EffectHelper.create_effect(actor, self, effect_key, effect_data, game_state)
	#if effect:
		#_actor_ids_to_effect_ids[actor.Id] = effect.Id
	#else:
		#ghfjkfsg
		#printerr("BaseZone._apply_inzone_effect: Failed to create Effect")
#
#
#func _on_turn_end(game_state:GameStateData):
	#if is_active:
		#for actor in game_state.map_data.get_actors_in_zone(self.Id):
			#_inflict_effect(actor, game_state)
	#pass
