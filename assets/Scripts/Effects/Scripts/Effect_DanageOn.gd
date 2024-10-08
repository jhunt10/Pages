class_name Effect_DamageOn
extends BaseEffect

var attack_power:int
var damage_type:String

func _init(actor:BaseActor, args:Dictionary) -> void:
	super(actor, args)
	attack_power = args['AttackPower']
	damage_type = args['DamageType']

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
	_actor.stats.apply_damage(attack_power, damage_type, _actor)
	CombatRootControl.Instance.create_damage_number(_actor, attack_power)
	pass
