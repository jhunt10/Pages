@tool
class_name MapMPathPointNode
extends Sprite2D

enum Direction {North, East, South, West}

@export var marker_name:String:
	set(val):
		marker_name = val
		if label:
			label.text = marker_name

@export var facing:Direction:
	set(val):
		facing = val
		if facing == Direction.North: self.rotation_degrees = 0
		elif facing == Direction.East: self.rotation_degrees = 90
		elif facing == Direction.South: self.rotation_degrees = 180
		elif facing == Direction.West: self.rotation_degrees = 270

@export var map_coor:Vector2i:
	set(val):
		map_coor = val
		var parent = get_parent()
		if parent and parent is MapPathNode:
			var granparent = parent.get_parent()
			if granparent and granparent is TileMapLayer:
				self.position = (granparent as TileMapLayer).map_to_local(map_coor) - parent.position
@export var label:Label
func _ready() -> void:
	set_notify_transform(true)

func get_map_pos()->MapPos:
	return MapPos.new(self.map_coor.x, self.map_coor.y, 0, self.facing)

var last_pos:Vector2
func _notification(what):
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		if last_pos == self.position:
			return
		if Input.is_mouse_button_pressed(1):
			return
		last_pos = self.position
		var parent = get_parent()
		if parent and parent is MapPathNode:
			var granparent = parent.get_parent()
			if granparent and granparent is TileMapLayer:
				map_coor = (granparent as TileMapLayer).local_to_map(parent.position + self.position)
		
