extends Control

@export var build_ques_button:Button
@export var show_statbars_button:Button
@export var fill_ammo_button:Button
@export var draw_button:Button
@export var auto_play_button:Button
@export var tigeer_button:Button
@export var timer_label:Label

@export var dev_map_display:Node2D

var auto_play = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	build_ques_button.pressed.connect(force_build_ques)
	show_statbars_button.pressed.connect(_toggle_stat_bars)
	fill_ammo_button.pressed.connect(_fill_ammo)
	draw_button.pressed.connect(_toggle_dev_map_display)
	auto_play_button.pressed.connect(_toggle_auto_play)
	tigeer_button.pressed.connect(_on_tigger)
	
	pass # Replace with function body.

func _toggle_dev_map_display():
	dev_map_display.visible = not dev_map_display.visible
	#CombatRootControl.Instance.ui_control.drop_message_control.add_card("Test Message")

var start_combat_timer = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var que_controller = CombatRootControl.QueController
	timer_label.self_modulate = Color.BLACK
	if que_controller.execution_state == ActionQueController.ActionStates.Waiting:
		timer_label.text = "Waiting"
		if auto_play and CombatRootControl.Instance.combat_started and not CombatRootControl.Instance.combat_finished:
			if start_combat_timer <= 0:
				start_combat_timer = 1
		if start_combat_timer > 0:
			start_combat_timer -= delta
			if start_combat_timer <= 0:
				AiHandler.build_action_ques(true)
				CombatUiControl.ui_state_controller.set_ui_state(UiStateController.UiStates.ExecRound)
				
	if que_controller.execution_state == ActionQueController.ActionStates.Running:
		if que_controller.sub_action_index == 0 or que_controller.sub_action_index == ActionQueController.FRAMES_PER_ACTION -1:
			timer_label.self_modulate = Color.RED
		timer_label.text = "%d:%02d" % [que_controller.action_index+1, que_controller.sub_action_index]
	if que_controller.execution_state == ActionQueController.ActionStates.Paused:
		timer_label.text = "Pause " + "%d:%02d" % [que_controller.action_index+1, que_controller.sub_action_index]
	queue_redraw()
	pass

func _toggle_stat_bars():
	CombatRootControl.Instance.ui_control.stats_collection_display.visible = !CombatRootControl.Instance.ui_control.stats_collection_display.visible 

func force_build_ques():
	AiHandler.build_action_ques(true)
	#for que:ActionQue in CombatRootControl.QueController._action_ques.values():
		#var actor = que.actor
		##if not actor.is_player:
		#actor.auto_build_que(0)

func _fill_ammo():
	for actor_id in CombatRootControl.Instance.GameState._actors.keys():
		if actor_id == null:
			continue
		var actor = CombatRootControl.Instance.GameState.get_actor(actor_id)
		if actor:
			actor.Que.fill_page_ammo()
			
func _toggle_auto_play():
	auto_play = !auto_play
	if auto_play:
		auto_play_button.text = "Auto: On"
	else:
		auto_play_button.text = "Auto: Off"

func _on_tigger():
	CombatRootControl.Instance.trigger_spawners()
