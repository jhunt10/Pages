extends Control

@export var build_ques_button:Button
@onready var timer_label:Label = $VBoxContainer/TimerContainer/Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	build_ques_button.pressed.connect(force_build_ques)
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
	queue_redraw()
	pass

func force_build_ques():
	for que:ActionQue in CombatRootControl.QueController._action_ques.values():
		var actor = que.actor
		#if not actor.is_player:
		actor.auto_build_que(0)
