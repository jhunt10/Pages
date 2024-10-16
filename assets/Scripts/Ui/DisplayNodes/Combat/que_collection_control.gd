class_name QueCollectionControl
extends Control

@onready var ques_container = $VBoxContainer

var _ques:Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CombatRootControl.QueController.que_ordering_changed.connect(_build_que_displays)
	CombatRootControl.QueController.que_marked_as_dead.connect(on_que_death)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_new_actor(actor:BaseActor):
	_build_que_displays()
	
func _build_que_displays():
	for que:QueDisplayControl in _ques.values():
		que.queue_free()
	_ques.clear()
	for que_id in CombatRootControl.QueController.que_order:
		var que:ActionQue = CombatRootControl.QueController._action_ques[que_id]
		var new_display:QueDisplayControl = load("res://Scenes/UiNodes/que_display_control.tscn").instantiate()
		new_display.set_actor(que.actor)
		ques_container.add_child(new_display)
		_ques[que.Id] = new_display

func on_que_death(que_id:String):
	var que_display:QueDisplayControl = _ques.get(que_id, null)
	if not que_display:
		return
	que_display.mark_as_dead()
	
