class_name QueCalcBarControl
extends HBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func build_slots(que:ActionQue):
	var section_size = 120 / max(que.get_max_que_size(),1)
	var box_prefab:NinePatchRect = self.get_child(0)
	for n in range(que.get_max_que_size()):
		var new_box:NinePatchRect = box_prefab.duplicate()
		new_box.custom_minimum_size = Vector2i(section_size*2, 32)
		new_box.visible = true
		self.add_child(new_box)
	box_prefab.queue_free()
	
func highlight_x(val:int):
	for bar:NinePatchRect in self.get_children():
		var rect = Rect2i(bar.position, bar.size)
		if rect.has_point(Vector2i(val, 1)):
			bar.self_modulate = Color.BLUE
		else:
			bar.self_modulate = Color.WHITE
