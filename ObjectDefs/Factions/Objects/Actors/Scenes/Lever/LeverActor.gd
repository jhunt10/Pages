class_name LeverActor
extends TrigerableActor

var state_on:bool

func on_combat_start():
	super()
	if not CombatRootControl.is_valid():
		return
	CombatRootControl.Instance.QueController.end_of_turn.connect(on_turn_end)
	CombatRootControl.Instance.QueController.end_of_round.connect(on_round_end)

func on_trigger(game_state:GameStateData):
	if not been_triggered:
		state_on = !state_on
		been_triggered = true
		triggered.emit(state_on)
		var gate_key = self.Id.trim_prefix("Lever_")
		if CombatRootControl.is_valid():
			CombatRootControl.Instance.MapController.set_gate_state(gate_key, state_on)
			game_state.map_data.set_gate_state(gate_key, state_on)
		

func on_round_end():
	been_triggered = false
	pass

func on_turn_end():
	been_triggered = false
	pass
