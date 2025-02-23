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
	var old_ques = {}
	for que_id in _ques.keys():
		var old_que = _ques[que_id]
		ques_container.remove_child(old_que)
		old_ques[que_id] = old_que
	_ques.clear()
	for que_id in CombatRootControl.QueController._que_order:
		var que:ActionQue = CombatRootControl.QueController._action_ques[que_id]
		if que.get_max_que_size() == 0:
			continue
		var new_display:QueCollection_QueDisplayContainer = null
		if old_ques.has(que_id):
			new_display = old_ques[que_id]
			old_ques.erase(que_id)
		else:
			new_display = premade_que_container.duplicate()
			new_display.set_actor(que.actor)
			
		ques_container.add_child(new_display)
		_ques[que.Id] = new_display
		new_display.show()
	
	for old_que in old_ques.values():
		old_que.queue_free()

func on_que_death(que_id:String):
	var que_display = _ques.get(que_id, null)
	if not que_display:
		return
	que_display.mark_as_dead()

func _on_frame_start():
	if _ques.size() == 0:
		return
	# set bar position
	if !color_bar.visible:
		color_bar.show()
	var first_que:QueCollection_QueDisplayContainer  = _ques.values()[0]
	var icon_width = first_que._slots[0].size.x
	var gap = first_que.slots_container.get_theme_constant('separation')
	var start_x = first_que.slots_container.position.x
	var end_x = first_que.slots_container.position.x + (first_que.slots_container.get_children().size() * (icon_width + gap)) - gap
	var x = start_x
	x += (icon_width + gap) * CombatRootControl.Instance.QueController.action_index
	x += (icon_width+gap) * CombatRootControl.Instance.QueController.sub_action_index / ActionQueController.FRAMES_PER_ACTION
	#print("QueQueBar: S|W|G: %s|%s|%s   Frame|Turn: %s|%s   X: %s " %[start_x, icon_width, gap, CombatRootControl.Instance.QueController.sub_action_index, CombatRootControl.Instance.QueController.action_index, x])
	color_bar.position = Vector2i(x, inner_container.position.y)
	color_bar.size.y = inner_container.size.y
