class_name TrapZone
extends BaseZone

# Triggers and Deals Damage when Actor enters Area. Destories self after triggering X times.

var _actor_ids_to_inzone_effect_ids:Dictionary = {}
var _inzone_effect_key:String


func _init(source:SourceTagChain, data:Dictionary, center:MapPos, area:AreaMatrix) -> void:
	super(source, data, center, area)
	CombatRootControl.QueController.end_of_round.connect(_on_round_end)

func on_actor_enter(actor:BaseActor, game_state:GameStateData):
	var damage_data = _data.get("DamageData")
	
	DamageHelper.handle_damage(get_source_actor(), actor, damage_data, _source, game_state)
	self._duration -= 1
	if _duration <= 0:
		_on_duration_end()

func _on_round_end():
	if node is ZoneTrapNode:
		node.start_arm_animation()
		CombatRootControl.QueController.end_of_round.disconnect(_on_round_end)
	
