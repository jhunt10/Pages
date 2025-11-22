class_name AttackMissile
extends BaseMissile


var _target_params:TargetParameters

func _init(source_actor:BaseActor, missile_data:Dictionary, source_tag_chain:SourceTagChain, 
			start_pos:MapPos, target_pos:MapPos, load_path:String) -> void:
	super(source_actor, missile_data, source_tag_chain, start_pos, target_pos, load_path)
	_target_params = missile_data.get("TargetParams", null)

func _do_missile_thing(game_state:GameStateData):
	if LOGGING: 
		print('Missile ' + str(Id) + " has done thing.")
	var source_actor = ActorLibrary.get_actor(_source_actor_id)
	if not source_actor:
		printerr("BaseMissile.do_thing: No Source Actor found with id '%s'." % [_source_actor_id])
		return
	var effected_actors = _get_actors_in_effect_area(game_state)
	if LOGGING: print("Found %s effected actors" % [effected_actors.size()])
	
	if effected_actors.size() > 0:
		var attack_event = AttackHandler.handle_attack(
			source_actor, 
			effected_actors, 
			_missle_data.get("AttackDetails", {}),
			{"MissileDamage":_missle_data['DamageData']},
			_missle_data.get("EffectDatas", []),
			_source_target_chain,
			game_state,
			_target_params.has_area_of_effect(),
			MapPos.Vector2i(StartSpot)
			)
		
		print("\n---------------------------")
		print(attack_event.serialize_self())
		print("---------------------------\n")
		

func _get_actors_in_effect_area(game_state:GameStateData)->Array:
	var effect_area = [TargetSpot]
	if _target_params.has_area_of_effect() and not _missle_data.get("IgnoreAOE", false):
		effect_area = _target_params.get_area_of_effect(MapPos.Vector2i(TargetSpot))
	
	var targets = []
	for spot in effect_area:
		for target_actor in game_state.get_actors_at_pos(spot):
			if !targets.has(target_actor):
				targets.append(target_actor)
	return targets
