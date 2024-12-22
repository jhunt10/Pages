class_name QueCollectionControl
extends BackPatchContainer

@export var ques_container:Container
@export var color_bar:ColorRect
@export var premade_que_container:QueCollection_QueDisplayContainer

var _ques:Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	if Engine.is_editor_hint(): return
	color_bar.hide()
	premade_que_container.hide()
	CombatRootControl.QueController.que_ordering_changed.connect(_build_que_displays)
	CombatRootControl.QueController.que_marked_as_dead.connect(on_que_death)
	CombatRootControl.QueController.start_of_frame.connect(_on_frame_start)
	CombatRootControl.QueController.end_of_round.connect(color_bar.hide)
	_build_que_displays()
	pass # Replace with function body.

func _process(delta: float) -> void:
	super(delta)

func _build_que_displays():
	for que in _ques.values():
		que.queue_free()
	_ques.clear()
	for que_id in CombatRootControl.QueController._que_order:
		var que:ActionQue = CombatRootControl.QueController._action_ques[que_id]
		if que.get_max_que_size() == 0:
			continue
		var new_display:QueCollection_QueDisplayContainer = premade_que_container.duplicate()
		new_display.visible = true
		new_display.set_actor(que.actor)
		ques_container.add_child(new_display)
		_ques[que.Id] = new_display
		new_display.show()

func on_que_death(que_id:String):
	var que_display = _ques.get(que_id, null)
	if not que_display:
		return
	que_display.mark_as_dead()

func _on_frame_start():
	# set bar position
	if !color_bar.visible:
		color_bar.show()
	var start_x = 38
	var icon_width = 32
	var gap = 4
	var x = start_x - self.global_position.x - (gap / 2)
	x += (icon_width + gap) * CombatRootControl.Instance.QueController.action_index
	x += (icon_width+gap) * CombatRootControl.Instance.QueController.sub_action_index / ActionQueController.FRAMES_PER_ACTION
	color_bar.position = Vector2i(x, inner_container.position.y)
	color_bar.size.y = inner_container.size.y
