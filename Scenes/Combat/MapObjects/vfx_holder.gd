class_name VfxHolder
extends Node2D

@export var actor_node:BaseActorNode
@export var flash_text_controller:FlashTextController

# Satalite Node on the ActorSprite for VFXs that follow the Actor
@export var offset_node:Node2D

var vfx_nodes = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if flash_text_controller:
		if not flash_text_controller.visible:
			flash_text_controller.show()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_vfx(vfx_node:BaseVfxNode):
	if vfx_nodes.keys().has(vfx_node.id):
		var old_vfx:BaseVfxNode = vfx_nodes[vfx_node.id]
		if old_vfx and is_instance_valid(old_vfx):
			old_vfx.finish()
	if vfx_node.parent_to_offset():
		offset_node.add_child(vfx_node)
	else:
		self.add_child(vfx_node)
	vfx_node.vfx_holder = self
	vfx_nodes[vfx_node.id] = vfx_node

func has_vfx(id:String)->bool:
	return vfx_nodes.keys().has(id)

func get_vfx(id:String)->BaseVfxNode:
	return vfx_nodes.get(id)

func remove_vfx(id:String):
	if vfx_nodes.keys().has(id):
		var old_vfx:BaseVfxNode = vfx_nodes[id]
		vfx_nodes.erase(id)
		if old_vfx and is_instance_valid(old_vfx):
			old_vfx.finish()
			old_vfx.queue_free()
