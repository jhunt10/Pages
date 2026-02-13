@tool
class_name GateSpriteNode
extends Node2D

@export var gate_key:String
@export var animation_player:AnimationPlayer
@export var is_open:bool
@export var map_coor:Vector2i:
	set(val):
		map_coor = val
		var parent = get_parent()
		if parent and parent is TileMapLayer:
			self.position = (parent as TileMapLayer).map_to_local(map_coor)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_notify_transform(true)
	pass # Replace with function body.

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
		
func get_occupied_coors()->Array:
	var coors =[map_coor]
	coors.append(Vector2i(map_coor.x + 1, map_coor.y))
	return coors

func open_gate():
	animation_player.play("open_gate")
	is_open = true

func close_gate():
	animation_player.play("close_gate")
	is_open = false
	
