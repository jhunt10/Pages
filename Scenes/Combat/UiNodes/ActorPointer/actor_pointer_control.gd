class_name ActorPointerControl
extends Control

@export var sprite:Sprite2D

var pointing_to_actor_node:BaseActorNode

func _ready() -> void:
	sprite.hide()


func _process(delta: float) -> void:
	if pointing_to_actor_node:
		var point_to_pos = pointing_to_actor_node.get_top_of_head_screen_position() 
		var view_port_rec = get_viewport_rect()
		# On Screen, Point to top of head
		if view_port_rec.has_point(point_to_pos):
			sprite.position = point_to_pos
			sprite.rotation_degrees = 0
		# Off Screen
		else:
			var center_pos = view_port_rec.get_center()
			sprite.position = get_screen_edge_intersection(center_pos, point_to_pos)
			sprite.look_at(point_to_pos)
			sprite.rotation_degrees -= 90
		

func set_pointing_to_actor(actor):
	var actor_node = actor
	if actor is String or actor is BaseActor:
		actor_node = CombatRootControl.get_actor_node(actor)
	pointing_to_actor_node = actor_node
	sprite.show()

func clear_pointing_to_actor(actor):
	var actor_node = actor
	if actor is String or actor is BaseActor:
		actor_node = CombatRootControl.get_actor_node(actor)
	if actor_node == pointing_to_actor_node:
		sprite.hide()
		pointing_to_actor_node = null

func get_screen_edge_intersection(start: Vector2, end: Vector2) -> Vector2:
	var vp_size = get_viewport_rect().size
	# Define the four edges of the screen (Left, Right, Top, Bottom)
	var edges = [
		[Vector2(0, 0), Vector2(0, vp_size.y)], # Left
		[Vector2(vp_size.x, 0), Vector2(vp_size.x, vp_size.y)], # Right
		[Vector2(0, 0), Vector2(vp_size.x, 0)], # Top
		[Vector2(0, vp_size.y), Vector2(vp_size.x, vp_size.y)] # Bottom
	]
	
	for edge in edges:
		var intersection = Geometry2D.segment_intersects_segment(edge[0], edge[1],start, end)
		if intersection != null:
			return intersection # Returns the first edge point intersected
			
	return end # Fallback if the line doesn't leave the screen
