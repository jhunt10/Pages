class_name TrapZone
extends BaseZone

# Triggers and Deals Damage when Actor enters Area. Destories self after triggering X times.
var _is_armed:bool = false

func _init(source:SourceTagChain, data:Dictionary, center:MapPos, area:AreaMatrix) -> void:
	super(source, data, center, area)
	CombatRootControl.QueController.end_of_round.connect(_on_round_end)

func on_actor_enter(actor:BaseActor, game_state:GameStateData):
	if _is_armed:
		var aoe_area_str = _data.get("AoeArea", "[[0,0]]")
		var aoe_matrix = AreaMatrix.new(aoe_area_str)
		var targets = []
		for spot in aoe_matrix.to_map_spots(_center_pos):
			var actors = game_state.get_actors_at_pos(spot)
			for sub_actor in actors:
				if not targets.has(sub_actor):
					targets.append(sub_actor)
		AttackHandler.handle_attack(
			get_source_actor(),
			targets,
			_data.get("AttackDetails", {}),
			_data.get("DamageDatas"),
			_data.get("EffectDatas", {}),
			_source, 
			game_state,
			true
		)
		#DamageHelper.handle_attack(
			#get_source_actor(), 
			#actor, 
			#_data.get("AttackDetails", {}),
			#_data.get("DamageDatas"),
			#_data.get("EffectDatas", {}),
			#_source, 
			#game_state,
			#null)
		self._duration -= 1
		if _duration <= 0:
			_on_duration_end()

func _on_round_end():
	if not _is_armed:
		_is_armed = true
		CombatRootControl.QueController.end_of_round.disconnect(_on_round_end)
	if node is ZoneTrapNode:
		node.start_arm_animation()
	
