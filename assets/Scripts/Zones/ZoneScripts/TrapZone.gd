class_name TrapZone
extends BaseZone

# Triggers and Deals Damage when Actor enters Area. Destories self after triggering X times.

var _actor_ids_to_inzone_effect_ids:Dictionary = {}
var _inzone_effect_key:String

var _is_armed:bool = false

func _init(source:SourceTagChain, data:Dictionary, center:MapPos, area:AreaMatrix) -> void:
	super(source, data, center, area)
	CombatRootControl.QueController.end_of_round.connect(_on_round_end)

func on_actor_enter(actor:BaseActor, game_state:GameStateData):
	if _is_armed:
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
	
