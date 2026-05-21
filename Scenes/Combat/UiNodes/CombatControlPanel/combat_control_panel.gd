class_name CombatControlPanel
extends PanelContainer

# Because I don't know how to have ui_controller access children of a scene 
signal menu_button_pressed
signal book_button_pressed

@export var min_button:TextureButton
@export var max_button:TextureButton
@export var menu_button:Button
@export var book_button:Button
@export var round_label:Label
@export var turn_label:Label
@export var status_label:Label
@export var round_progress_bar:ProgressBar

@export var turns_container:Container

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	min_button.pressed.connect(_on_min_button)
	max_button.pressed.connect(_on_max_button)
	menu_button.pressed.connect(menu_button_pressed.emit)
	book_button.pressed.connect(book_button_pressed.emit)
	CombatRootControl.Instance.QueController.start_of_turn.connect(_on_turn_start)
	CombatRootControl.Instance.QueController.start_of_round.connect(_on_round_start)
	CombatRootControl.Instance.QueController.end_of_round.connect(_on_round_end)

func _process(delta: float) -> void:
	if round_progress_bar.visible:
		var turn_index = CombatRootControl.Instance.QueController.action_index
		var frame_index = CombatRootControl.Instance.QueController.sub_action_index 
		
		var total_frames:float = ActionQueController.FRAMES_PER_ACTION * CombatRootControl.Instance.QueController.max_que_size
		var cur_frame:float = (turn_index * ActionQueController.FRAMES_PER_ACTION) + frame_index
		var progress:float = (cur_frame / total_frames) * 100.0
		print(progress)
		round_progress_bar.value = progress

func _on_min_button():
	min_button.hide()
	max_button.show()
	turns_container.hide()

func _on_max_button():
	max_button.hide()
	min_button.show()
	turns_container.show()

func _on_turn_start():
	var turn_number = CombatRootControl.Instance.QueController.action_index
	var round_number = CombatRootControl.Instance.QueController.round_counter
	round_label.text = str(round_number+1)
	turn_label.text = str(turn_number+1)

func _on_round_start():
	round_progress_bar.value = 0
	round_progress_bar.show()

func _on_round_end():
	var round_number = CombatRootControl.Instance.QueController.round_counter
	round_label.text = str(round_number+1)
	turn_label.text = str(0)
	round_progress_bar.hide()

func set_status(val:String):
	status_label.text = val
	
