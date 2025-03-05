class_name VfxHolder
extends Node2D

var vfx_nodes = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_vfx(id:String, vfx_node):
	if vfx_nodes.keys().has(id):
		var old_vfx = vfx_nodes[id]
		if old_vfx and is_instance_valid(old_vfx):
			old_vfx.queue_free()
	self.add_child(vfx_node)
	vfx_nodes[id] = vfx_node

func has_vfx(id:String)->bool:
	return vfx_nodes.keys().has(id)
	
func remove_vfx(id:String):
	if vfx_nodes.keys().has(id):
		var old_vfx = vfx_nodes[id]
		vfx_nodes.erase(id)
		if old_vfx and is_instance_valid(old_vfx):
			old_vfx.on_delete()
			old_vfx.queue_free()
