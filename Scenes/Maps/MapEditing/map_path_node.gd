@tool
class_name MapPathNode
extends Node2D

enum Direction {North, East, South, West}

@export var marker_name:String:
	set(val):
		marker_name = val
		if label:
			label.text = marker_name

@export var facing:Direction:
	set(val):
		facing = val
		if sprite:
			if facing == Direction.North: sprite.rotation_degrees = 0
			elif facing == Direction.East: sprite.rotation_degrees = 90
			elif facing == Direction.South: sprite.rotation_degrees = 180
			elif facing == Direction.West: sprite.rotation_degrees = 270

@export var map_coor:Vector2i:
	set(val):
		map_coor = val
		var parent = get_parent()
		if parent and parent is TileMapLayer:
			self.position = (parent as TileMapLayer).map_to_local(map_coor)

@export var sprite:Sprite2D
@export var label:Label

func _ready() -> void:
	set_notify_transform(true)

func get_map_pos()->MapPos:
	return MapPos.new(self.map_coor.x, self.map_coor.y, 0, self.facing)

func get_path_poses()->Array:
	var out_list = [self.get_map_pos()]
	for child in get_children():
		if not child is MapMPathPointNode:
			continue
		var marker = child as MapMPathPointNode
		out_list.append(marker.get_map_pos())
	return out_list

func get_last_pos()->MapPos:
	var poses = get_path_poses()
	return poses[-1]

var last_pos:Vector2
func _notification(what):
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		if last_pos == self.position:
			return
		if Input.is_mouse_button_pressed(1):
			return
		last_pos = self.position
		var parent = get_parent()
		if parent and parent is TileMapLayer:
			map_coor = (parent as TileMapLayer).local_to_map(self.position)
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()
	pass

func _draw() -> void:
	var last_pos = Vector2(0,0)
	for child in get_children():
		if not child is MapMPathPointNode:
			continue
		var marker = child as MapMPathPointNode
		var pos = marker.position
		#if last_pos:
		draw_line(last_pos, pos, Color.RED, 1.0)
		last_pos = pos
