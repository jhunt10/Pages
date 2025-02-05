class_name SpotLightControl
extends Control

@export var actor_sprite:Sprite2D

var actor_node:ActorNode

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if actor_node:
		var global_trans  = actor_node.actor_motion_node.get_global_transform_with_canvas()
		self.position = global_trans.origin
		self.scale = global_trans.get_scale()
		actor_sprite.frame_coords = actor_node.actor_sprite.frame_coords


func set_actor(actor_id:String):
	actor_node = CombatRootControl.Instance.get_actor_node(actor_id)
	actor_sprite.texture = actor_node.actor_sprite.texture
	var global_trans  = actor_node.get_global_transform_with_canvas()
	self.position = global_trans.origin
	self.scale = global_trans.get_scale()
	actor_sprite.frame_coords = actor_node.actor_sprite.frame_coords
	self.visible = true
