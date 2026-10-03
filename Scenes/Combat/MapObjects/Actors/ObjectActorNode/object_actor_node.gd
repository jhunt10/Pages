@tool
class_name ObjectActorNode
extends BaseActorNode

@export var actor_key:String
@export var unique_id:String

@export var facing:MapPos.Directions:
	set(val):
		facing = val
		self.set_facing_dir(facing)

@export var map_coor:Vector2i:
	set(val):
		map_coor = val
		var parent = get_parent()
		if parent and parent is TileMapLayer:
			self.position = (parent as TileMapLayer).map_to_local(map_coor)

@export var sprite_offset:Vector2i:
	set(val):
		sprite_offset = val
		if offset_node:
			offset_node.position = sprite_offset

@export var sprite_w_h:Vector2i:
	set(val):
		sprite_w_h = val
		if actor_sprite:
			actor_sprite.hframes = val.x
			actor_sprite.vframes = val.y

@export var actor_sprite_sheet:Texture2D:
	set(val):
		if actor_sprite:
			actor_sprite.texture = val
	get:
		if actor_sprite:
			return actor_sprite.texture
		return null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		set_notify_transform(true)
	else:
		super()

var last_pos:Vector2
func _notification(what):
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		if last_pos == self.position:
			return
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			return
		last_pos = self.position
		var parent = get_parent()
		if parent and parent is TileMapLayer:
			#if parent.tile_set:
			map_coor = (parent as TileMapLayer).local_to_map(self.position)

func set_actor(actor:BaseActor, connect_signals=true):
	Id = actor.Id
	Actor = actor
	self.name = actor.Id
	if connect_signals and not actor.on_move.is_connected(_on_actor_moved):
		#actor.on_move_failed.connect(_on_movement_failed)
		#actor.action_failed.connect(_on_action_failed)
		actor.on_move.connect(_on_actor_moved)
		actor.on_death.connect(_on_actor_death)
		actor.on_revive.connect(_on_actor_revive)
	#var sprite_data = actor.get_load_val("SpriteData") 
	#if sprite_data.keys().has("SpriteFrameWH"):
		#var frames = sprite_data.get("SpriteFrameWH", [1,1])
		#actor_sprite.hframes = frames[0]
		#actor_sprite.vframes = frames[1]
	#
	#if sprite_data.keys().has("SpriteOffset"):
		#var offset = sprite_data.get("SpriteOffset", [0,0])
		#offset_node.position = Vector2i(offset[0], offset[1])
	#
	#actor_sprite.texture = Actor.sprite.get_body_sprite()

func get_spawn_map_pos()->MapPos:
	var pos = MapPos.Vector2i(self.map_coor)
	pos.dir = self.facing_dir
	return pos

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	super(delta)

func ready_action_animation(_action_name:String, _speed:float=1, _off_hand:bool=false):
	return

func execute_action_motion_animation(_speed:float=1, _off_hand:bool=false):
	return
func cancel_action_animations():
	return
