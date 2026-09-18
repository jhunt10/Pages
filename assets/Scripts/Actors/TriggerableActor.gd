class_name TrigerableActor
extends BaseActor

signal triggered

var been_triggered:bool = false

func on_combat_start():
	super()
	if not CombatRootControl.is_valid():
		printerr("TrigerableActor.on_combat_start: CombatRootControl is not valid")
		return

func apply_damage_event(_damage_event:DamageEvent, _trigger_effect:bool=false, game_state:GameStateData=null):
	on_trigger(game_state)

func apply_healing(_value:int, _can_revive:bool=false):
	on_trigger(CombatRootControl.Instance.GameState)

func on_trigger(_game_state:GameStateData):
	been_triggered = true
	triggered.emit()
