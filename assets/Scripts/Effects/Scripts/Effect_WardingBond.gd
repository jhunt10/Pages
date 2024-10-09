class_name Effect_WardingBond
extends BaseEffect

var damage_reduction:float = 0.5
var damage_transfer:float = 0.5

func _init(actor:BaseActor, args:Dictionary) -> void:
	super(actor, args)
	

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
	#_actor.stats.add_to_bar_stat(stat_name, regen_amount)
	#CombatRootControl.Instance.create_damage_number(_actor, attack_power)
	pass
