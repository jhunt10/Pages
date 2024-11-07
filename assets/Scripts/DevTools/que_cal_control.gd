extends Control

@onready var box_list:VBoxContainer = $VBoxContainer
@onready var que_bar_prefab:QueCalcBarControl = $VBoxContainer/QueSlotsContainer
@onready var red_bar:TextureRect = $RedBar

var que_bars:Dictionary = {}
var max_que_size = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	que_bar_prefab.visible = false
	CombatRootControl.Instance.actor_spawned.connect(on_actor_spawn)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if CombatRootControl.QueController.execution_state == ActionQueController.ActionStates.Waiting:
		var mouse_pos = get_local_mouse_position()
		if mouse_pos.x > 0 and mouse_pos.x < self.size.x:
			red_bar.position = Vector2i(min(max(mouse_pos.x, 8), self.size.x - 8), 0)
		for bar in que_bars.values():
			bar.highlight_x(mouse_pos.x-8)
	else:
		var que_control = CombatRootControl.QueController
		var section_size = 240 / max_que_size
		var current_x = que_control.action_index * section_size
		current_x += (section_size / 24) * que_control.sub_action_index
		red_bar.position = Vector2i(current_x,0)
		for bar in que_bars.values():
			bar.highlight_x(current_x)
		
	pass

func on_actor_spawn(actor):
	que_bars[actor.Id] = add_que(actor.Que)

func add_que(que:ActionQue):
	var section_size = 120 / max(que.get_max_que_size(),1)
	if que.get_max_que_size() > max_que_size:
		max_que_size = que.get_max_que_size()
	var new_que:QueCalcBarControl = que_bar_prefab.duplicate()
	new_que.build_slots(que)
	new_que.visible = true
	box_list.add_child(new_que)
	return new_que
