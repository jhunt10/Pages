class_name LeverActor
extends BaseActor

signal triggered(on:bool)

var triggered_already:bool = false
var state_on:bool

func on_combat_start():
	super()
	if not CombatRootControl.is_valid():
		printerr("ObjectActor.on_combat_start: CombatRootControl is not valid")
		return
	CombatRootControl.Instance.QueController.end_of_turn.connect(on_turn_end)
	CombatRootControl.Instance.QueController.end_of_round.connect(on_round_end)

func apply_damage_event(damage_event:DamageEvent, trigger_effect:bool=false, game_state:GameStateData=null):
	on_trigger(game_state)

func apply_damage(damage):
	on_trigger(CombatRootControl.Instance.GameState)

func apply_healing(value:int, can_revive:bool=false):
	on_trigger(CombatRootControl.Instance.GameState)

func on_trigger(game_state:GameStateData):
	if not triggered_already:
		state_on = !state_on
		triggered_already = true
		triggered.emit(state_on)
		var gate_key = self.Id.trim_prefix("Lever_")
		if CombatRootControl.is_valid():
			CombatRootControl.Instance.MapController.set_gate_state(gate_key, state_on)
			game_state.map_data.set_gate_state(gate_key, state_on)
		

func on_round_end():
	triggered_already = false
	pass

func on_turn_end():
	triggered_already = false
	pass
