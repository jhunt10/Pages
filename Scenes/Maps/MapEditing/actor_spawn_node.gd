@tool
class_name ActorSpawnNode
extends Sprite2D

enum Direction {North, East, South, West}
enum SpawnBy {Player, Key, Id}

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
		if parent and parent is TileMapLayer:
			self.position = (parent as TileMapLayer).map_to_local(map_coor)

@export var spawn_actor_by:SpawnBy:
	set(val):
		spawn_actor_by = val
		if spawn_actor_by == SpawnBy.Player:
			spawn_actor_value = "Player"
			self.self_modulate = Color.GREEN
		if spawn_actor_by == SpawnBy.Key:
			self.self_modulate = Color.AQUA
		if spawn_actor_by == SpawnBy.Id:
			self.self_modulate = Color.RED
@export var spawn_actor_value:String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_notify_transform(true)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


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
			#if parent.tile_set:
			map_coor = (parent as TileMapLayer).local_to_map(self.position)
		
