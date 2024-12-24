@tool
class_name MapMarkerNode
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
		if self.vframes == 1:
			self.frame = 0
			if facing == Direction.North: self.rotation_degrees = 0
			elif facing == Direction.East: self.rotation_degrees = 90
			elif facing == Direction.South: self.rotation_degrees = 180
			elif facing == Direction.West: self.rotation_degrees = 270
		else:
			self.rotation_degrees = 0
			if facing == Direction.North: self.frame = 12
			elif facing == Direction.East: self.frame = 24
			elif facing == Direction.South: self.frame = 0
			elif facing == Direction.West: self.frame = 36

@export var map_coor:Vector2i:
	set(val):
		map_coor = val
		var parent = get_parent()
		if parent and parent is TileMapLayer:
			self.position = (parent as TileMapLayer).map_to_local(map_coor)
@export var label:Label
func _ready() -> void:
	set_notify_transform(true)

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
		
