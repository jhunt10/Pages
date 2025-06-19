class_name MoveableCamera2D
extends Camera2D

const LOGGING = false

signal panning_finished

@export var speed:float = 200
@export var canvas_layer:CanvasLayer

var freeze:bool:
	set(val):
		freeze = val
		if freeze: printerr("****** Freezing Camera")
		else: printerr("****** UNFreezing Camera")

var locked_for_cut_scene:bool = false

var following_actor_node:BaseActorNode

var is_auto_panning:bool:
	get: return auto_pan_start_pos != null
var auto_pan_start_pos
var auto_pan_target_pos
var auto_pan_velocity:float
var auto_pan_max_velocity:float = 500
var auto_pan_min_velocity:float = 100

# For ignoring scrolling
@export var message_box:Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Camera must be later in tree than Actors, otherwise camera will bounce around when the actor walks between tiles
func lock_to_actor(actor:BaseActor):
	if LOGGING: print("Camera lock to actor: %s" %[actor.Id] )
	var actor_node = CombatRootControl.get_actor_node(actor.Id)
	if not actor_node:
		printerr("Camera lock_to_actor: Failed to find node for actor: %s" % [actor.Id])
	self.snap_to_map_pos(actor_node.cur_map_pos)
	following_actor_node = actor_node
	if LOGGING: print("Locking Camera to Actor: %s" % [following_actor_node.Actor.Id])
	

func snap_to_map_pos(pos):
	var map = CombatRootControl.Instance.MapController
	var tile_pos = map.actor_tile_map.map_to_local(Vector2i(pos.x, pos.y))
	var screen_center = self.get_screen_center_position()
	self.position = tile_pos
	if LOGGING: print("SnapToPos: pos: %s | tile_pos: %s | SelfPos: %s | MapPos: %s" % [pos, tile_pos, self.get_screen_center_position(), map.actor_tile_map.position])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if auto_pan_start_pos:
		var distance_from = self.position.distance_to(auto_pan_start_pos)
		var distance_to = self.position.distance_to(auto_pan_target_pos)
		var full_dist = auto_pan_start_pos.distance_to(auto_pan_target_pos)
		var dist_fact = distance_from / full_dist * 2
		if distance_to < distance_from:
			dist_fact = distance_to / full_dist * 2
		auto_pan_velocity = auto_pan_min_velocity + ((auto_pan_max_velocity - auto_pan_min_velocity) * dist_fact)
		#if dist_fact > 0.5:
			#auto_pan_velocity = min_v
		#else:
			#auto_pan_velocity = max(auto_pan_velocity - (auto_pan_acceleration), auto_pan_min_velocity)
		#print("AutoPan Fact: %s | Vel: %s " % [dist_fact, auto_pan_velocity])
		var new_pos:Vector2 = self.position.move_toward(auto_pan_target_pos, delta * auto_pan_velocity) 
		if new_pos == self.position:
			force_finish_panning()
			return
		else:
			self.position = new_pos
			return
	
	if following_actor_node:
		if not is_instance_valid(following_actor_node):
			clear_following_actor()
		else:
			var move_node = following_actor_node.actor_motion_node
			if LOGGING: print("Following Actor: " + str(move_node.position))
			set_camera_pos(move_node.global_position, false)
			return
	if freeze:
		return
	if locked_for_cut_scene:
		return
	var dist = delta * speed
	if Input.is_key_pressed(KEY_W):
		set_camera_pos(self.position + Vector2(0, -dist))
	if Input.is_key_pressed(KEY_S):
		set_camera_pos(self.position + Vector2(0, dist))
	if Input.is_key_pressed(KEY_A):
		set_camera_pos(self.position + Vector2(-dist, 0))
	if Input.is_key_pressed(KEY_D):
		set_camera_pos(self.position + Vector2(dist, 0))
	if _touch_events.size() > 0:
		#if LOGGING: print(str(_touch_events))
		if _touch_events.size() == 1:
			var touch_events = _touch_events.values()[0]
			var drag_diff = touch_events['start'].position - touch_events['current'].position 
			set_camera_pos(_drag_start_camera_pos + (drag_diff / self.zoom))
			if LOGGING: print(self.position)
		if _touch_events.size() == 2:
			var center_point = Vector2.ZERO
			for touch in _touch_events.values():
				touch['start'].position = touch['current'].position
				center_point += touch['current'].position
			center_point = center_point / 2
			var radius = center_point.distance_to(_touch_events.values()[0]['current'].position)
			if LOGGING: print("Center: %s | Radius: %s" % [center_point, radius])
			if _pinch_start_radius <= 0:
				_pinch_start_radius = radius
				#_pinch_last_radius = radius
				return
			var pinch_change = radius / _pinch_start_radius
			if pinch_change != 1:
				var new_zoom = min(10, max(1, _pinch_start_zoom.x * pinch_change))
				self.zoom = Vector2(new_zoom, new_zoom)
				if LOGGING: print("New Zoom: %s" % [self.zoom])
			if LOGGING: print("Radius Change: R:%s | Start:%s | Change: %s" % [radius, _pinch_start_radius, pinch_change] )
			#_pinch_last_radius = radius
	pass

func clear_following_actor():
	if following_actor_node:
		if is_instance_valid(following_actor_node):
			if LOGGING: print("Unlocking Camera from Actor: %s" % [following_actor_node.Actor.Id])
		following_actor_node = null
	else:
		if LOGGING: print("Unlocking Camera from Actor: null")

func set_camera_pos(pos:Vector2, unfollow:bool=true):
	self.position = pos
	if unfollow and following_actor_node:
		clear_following_actor()

func start_auto_pan(target_pos:Vector2):
	_touch_events.clear()
	clear_following_actor()
	auto_pan_start_pos = self.position
	auto_pan_target_pos = target_pos
	auto_pan_velocity = auto_pan_min_velocity

func start_auto_pan_to_map_pos(map_pos:MapPos):
	var target_pos = MapHelper.get_map_pos_global_position(map_pos)
	start_auto_pan(target_pos)

func start_auto_pan_to_actor(actor:BaseActor, lock_to_actor:bool=true):
	var target_pos = MapHelper.get_actor_global_position(actor)
	var actor_node = CombatRootControl.Instance.MapController.actor_nodes.get(actor.Id)
	if lock_to_actor:	
		following_actor_node = actor_node
	start_auto_pan(target_pos)

func force_finish_panning():
	if not is_auto_panning:
		return
	self.position = auto_pan_target_pos
	auto_pan_target_pos = null
	auto_pan_start_pos = null
	panning_finished.emit()

func _input(event: InputEvent) -> void:
	if freeze or is_auto_panning:
		return
	if locked_for_cut_scene:
		return

var _touch_events:Dictionary = {}
var _drag_start_camera_pos:Vector2
var _pinch_start_radius:float
var _pinch_last_radius:float
var _pinch_start_zoom:Vector2
func _unhandled_input(event: InputEvent) -> void:
	if freeze or is_auto_panning:
		return
	if locked_for_cut_scene:
		return
	if event is InputEventScreenTouch and event.pressed:
		if _touch_events.size() == 0:
			_drag_start_camera_pos = self.position
		_touch_events[event.index] = {"current": event, "start":event}
		if _touch_events.size() == 2:
			_pinch_start_zoom = self.zoom
	if event is InputEventScreenTouch and not event.pressed:
		_touch_events.erase(event.index)
		if _touch_events.size() < 2:
			_pinch_start_radius = -1
			_pinch_last_radius = -1
	if event is InputEventScreenDrag:
		if _touch_events.keys().has(event.index):
			_touch_events[event.index]["current"] = event
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		
		var can_scroll = true
		if message_box:
			var mouse_pos = message_box.back_patch.get_local_mouse_position()
			var no_touch = message_box.back_patch.get_global_rect()
			no_touch.position.x = 0
			no_touch.position.y = 0
			if no_touch.has_point(mouse_pos):
				can_scroll = false
		if can_scroll:
			var new_zoom = self.zoom
			if mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
				new_zoom += Vector2(0.1, 0.1)
			if mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				new_zoom -= Vector2(0.1, 0.1)
			self.zoom = Vector2(max(1, new_zoom.x), max(1, new_zoom.y))
		
