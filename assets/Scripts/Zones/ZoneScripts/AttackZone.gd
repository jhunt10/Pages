class_name AttackZone
extends BaseZone

# Makes an AOE Attack against Actors inside Zone on Trigger

# For more advanced triggers, use EffectZone to apply an Effect to apply the Attacks 
enum AttackZoneTriggers {
	# Individual Actor Triggers
	OnEnter, OnExit, 
	# All Actors At Once
	OnCreate, OnDurationEnds, EndOfTurn, EndOfRound
}

var _triggers:Array = []

func _init(source:SourceTagChain, data:Dictionary, center:MapPos, area:AreaMatrix) -> void:
	super(source, data, center, area)
	var attack_data:Dictionary = _data.get("AttackDetails", {})
	if attack_data.size() == 0:
		printerr("AttackZone: Created without AttackDetails")
		is_active = false
		return
	for trig_str in _data.get("Triggers", []):
		if AttackZoneTriggers.keys().has(trig_str):
			_triggers.append(AttackZoneTriggers[trig_str])
	if _triggers.has(AttackZoneTriggers.EndOfTurn):
		CombatRootControl.Instance.QueController.end_of_turn_with_state.connect(_trigger_attacks)
	if _triggers.has(AttackZoneTriggers.EndOfRound):
		CombatRootControl.Instance.QueController.end_of_round_with_state.connect(_trigger_attacks)
	

func _on_duration_end():
	super()
	if _triggers.has(AttackZoneTriggers.OnDurationEnds):
		_trigger_attacks(CombatRootControl.Instance.GameState)
	if CombatRootControl.Instance.QueController.end_of_turn_with_state.is_connected(_trigger_attacks):
		CombatRootControl.Instance.QueController.end_of_turn_with_state.disconnect(_trigger_attacks)
	if CombatRootControl.Instance.QueController.end_of_round_with_state.is_connected(_trigger_attacks):
		CombatRootControl.Instance.QueController.end_of_round_with_state.disconnect(_trigger_attacks)


func on_actor_enter(actor:BaseActor, game_state:GameStateData):
	super(actor, game_state)
	if _triggers.has(AttackZoneTriggers.OnEnter):
		_do_single_attack(actor, game_state)
	
func on_actor_exit(actor:BaseActor, game_state:GameStateData):
	super(actor, game_state)
	if _triggers.has(AttackZoneTriggers.OnExit):
		_do_single_attack(actor, game_state)

func _do_single_attack(actor:BaseActor, game_state:GameStateData):
	var attack_event = AttackHandler.handle_attack(
		get_source_actor(),
		[actor],
		_data.get("AttackDetails", {}),
		_data.get("DamageDatas", {}),
		_data.get("EffectDatas", {}),
		_source,
		game_state,
		true,
		game_state.get_actor_pos(actor)
	)

func _trigger_attacks(game_state:GameStateData):
	var actors = list_actors_in_zone(game_state)
	var attack_event = AttackHandler.handle_attack(
		get_source_actor(),
		actors,
		_data.get("AttackDetails", {}),
		_data.get("DamageDatas", {}),
		_data.get("EffectDatas", {}),
		_source,
		game_state,
		true
	)
