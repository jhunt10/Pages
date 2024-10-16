extends Control

@onready var timer_label:Label = $VBoxContainer/TimerContainer/Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var que_controller = CombatRootControl.QueController
	timer_label.self_modulate = Color.BLACK
	if que_controller.execution_state == ActionQueController.ActionStates.Waiting:
		timer_label.text = "Waiting"
	if que_controller.execution_state == ActionQueController.ActionStates.Running:
		if que_controller.sub_action_index == 0 or que_controller.sub_action_index == ActionQueController.FRAMES_PER_ACTION -1:
			timer_label.self_modulate = Color.RED
		timer_label.text = "%d:%02d" % [que_controller.action_index+1, que_controller.sub_action_index]
	if que_controller.execution_state == ActionQueController.ActionStates.Paused:
		timer_label.text = "Pause " + "%d:%02d" % [que_controller.action_index+1, que_controller.sub_action_index]
	pass
