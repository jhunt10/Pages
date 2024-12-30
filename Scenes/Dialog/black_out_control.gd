@tool
class_name BlackOutControl
extends ColorRect

enum BLACKOUT_STATE {Black, FadeIn, Clear, FadeOut}

signal fade_done

@export var fade_speed:float = 1

@export var _state:BLACKOUT_STATE:
	set(val):
		if _state != val:
			_state = val
			if _state == BLACKOUT_STATE.Black:
				self.self_modulate.a = 1
			elif _state == BLACKOUT_STATE.FadeIn:
				self.self_modulate.a = 1
			elif _state == BLACKOUT_STATE.Clear:
				self.self_modulate.a = 0
			elif _state == BLACKOUT_STATE.FadeOut:
				self.self_modulate.a = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _state == BLACKOUT_STATE.FadeIn:
		self_modulate.a = max(0, self_modulate.a - (delta * fade_speed))
		if self_modulate.a == 0:
			_state = BLACKOUT_STATE.Clear
			fade_done.emit()
	if _state == BLACKOUT_STATE.FadeOut:
		self_modulate.a = min(1, self_modulate.a + (delta * fade_speed))
		if self_modulate.a == 1:
			_state = BLACKOUT_STATE.Black
			fade_done.emit()

func set_state_string(state_str):
	var state =  BLACKOUT_STATE.get(state_str)
	if state == null:
		printerr("BlackOutControl: Unknown state '%s'." %[state_str])
	_state = state
	print("BlackOutControl: Set State: %s" % [state_str])
