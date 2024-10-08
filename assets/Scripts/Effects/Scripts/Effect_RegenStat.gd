class_name Effect_RegenStat
extends BaseEffect

var regen_amount:int
var stat_name:String

func _init(actor:BaseActor, args:Dictionary) -> void:
	super(actor, args)
	regen_amount = args['Amount']
	stat_name = args['StatName']

func _on_duration_end():
	pass

func _on_turn_start():
	if Triggers.has(EffectTriggers.OnTurnStart):
		do_effect()

func _on_turn_end():
	if Triggers.has(EffectTriggers.OnTurnEnd):
		do_effect()

func _on_round_start():
	if Triggers.has(EffectTriggers.OnRoundStart):
		do_effect()

func _on_round_end():
	if Triggers.has(EffectTriggers.OnRoundEnd):
		do_effect()

func _on_move(_old_pos:MapPos, _new_pos:MapPos, _move_type:String, _moved_by:BaseActor):
	if Triggers.has(EffectTriggers.OnMove):
		do_effect()

func do_effect():
	_actor.stats.add_to_bar_stat(stat_name, regen_amount)
	#CombatRootControl.Instance.create_damage_number(_actor, attack_power)
	pass
