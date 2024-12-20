class_name QueCollectionControl
extends Control

@export var ques_container:Container

var _ques:Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CombatRootControl.QueController.que_ordering_changed.connect(_build_que_displays)
	CombatRootControl.QueController.que_marked_as_dead.connect(on_que_death)
	_build_que_displays()
	pass # Replace with function body.

func _build_que_displays():
	for que:QueMinDisplayContainer in _ques.values():
		que.queue_free()
	_ques.clear()
	for que_id in CombatRootControl.QueController._que_order:
		var que:ActionQue = CombatRootControl.QueController._action_ques[que_id]
		if que.get_max_que_size() == 0:
			continue
		var new_display:QueMinDisplayContainer = load("res://Scenes/Combat/UiNodes/QueDisplay/mini_que_display_container.tscn").instantiate()
		new_display.visible = true
		new_display.set_actor(que.actor)
		ques_container.add_child(new_display)
		_ques[que.Id] = new_display

func on_que_death(que_id:String):
	var que_display:QueMinDisplayContainer = _ques.get(que_id, null)
	if not que_display:
		return
	que_display.mark_as_dead()
	
