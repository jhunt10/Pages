class_name EffectHolder

var _actor:BaseActor
var _effects:Dictionary = {}
var _triggers_to_ids:Dictionary = {}
var _system_triggers_to_ids:Dictionary = {}

func _init(actor:BaseActor) -> void:
	_actor = actor
	
	for t in BaseEffect.EffectTriggers.values():
		_triggers_to_ids[t] = []
		_system_triggers_to_ids[t] = []
	
	# Connect signals
	if CombatRootControl.Instance:
		CombatRootControl.Instance.QueController.start_of_turn.connect(_on_turn_start)
		CombatRootControl.Instance.QueController.end_of_turn.connect(_on_turn_end)
		CombatRootControl.Instance.QueController.start_of_round.connect(_on_round_start)
		CombatRootControl.Instance.QueController.end_of_round.connect(_on_round_end)
		actor.on_move.connect(_on_actor_moved)
	
func add_effect(effect_key:String, effect_data:Dictionary)->BaseEffect:
	var effect = MainRootNode.effect_libary.create_new_effect(effect_key, _actor, effect_data)
	
	if effect.is_instant:
		effect.do_effect()
		return effect
	
	_effects[effect.Id] = effect
	for trigger in effect.Triggers:
		_triggers_to_ids[trigger].append(effect.Id)
	for trigger in effect.system_triggers:
		_system_triggers_to_ids[trigger].append(effect.Id)
	return effect
		
func get_effect(effect_id:String)->BaseEffect:
	if _effects.keys().has(effect_id):
		return _effects[effect_id]
	return null
		
func remove_effect(effect:BaseEffect):
	print("Remove Effect: " + effect.EffectKey + " from " + _actor.ActorKey)
	if !_effects.has(effect.Id):
		printerr("Unknown effect: " + effect.Id)
		return
	_effects.erase(effect.Id)
	for trigger in effect.Triggers:
		_triggers_to_ids[trigger].erase(effect.Id)
	for trigger in effect.system_triggers:
		_system_triggers_to_ids[trigger].erase(effect.Id)

func _on_turn_start():
	for id in _system_triggers_to_ids[BaseEffect.EffectTriggers.OnTurnStart]:
		_effects[id]._system_on_turn_start()
	for id in _triggers_to_ids[BaseEffect.EffectTriggers.OnTurnStart]:
		_effects[id]._on_turn_start()

func _on_turn_end():
	for id in _triggers_to_ids[BaseEffect.EffectTriggers.OnTurnEnd]:
		_effects[id]._on_turn_end()
	for id in _system_triggers_to_ids[BaseEffect.EffectTriggers.OnTurnEnd]:
		_effects[id]._system_on_turn_end()

func _on_round_start():
	for id in _system_triggers_to_ids[BaseEffect.EffectTriggers.OnRoundStart]:
		_effects[id]._system_on_round_start()
	for id in _triggers_to_ids[BaseEffect.EffectTriggers.OnRoundStart]:
		_effects[id]._on_round_start()

func _on_round_end():
	for id in _triggers_to_ids[BaseEffect.EffectTriggers.OnRoundEnd]:
		_effects[id]._on_round_end()
	for id in _system_triggers_to_ids[BaseEffect.EffectTriggers.OnRoundEnd]:
		_effects[id]._system_on_round_end()
		
func _on_actor_moved(old_pos:MapPos, new_pos:MapPos, move_type:String, moved_by:BaseActor):
	for id in _triggers_to_ids[BaseEffect.EffectTriggers.OnMove]:
		_effects[id]._on_move(old_pos, new_pos, move_type, moved_by)
	
