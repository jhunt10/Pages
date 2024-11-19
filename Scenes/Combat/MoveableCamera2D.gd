class_name MoveableCamera2D
extends Camera2D

const LOGGING = false

@export var speed:float = 200
var freeze:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func snap_to_position(vec:Vector2):
	self.offset = vec

func snap_to_map_pos(pos):
	var map = CombatRootControl.Instance.MapController
	var tile_pos = map.actor_tile_map.map_to_local(Vector2i(pos.x, pos.y))
	var screen_center = self.get_screen_center_position()
	self.position = tile_pos
	if LOGGING: print("SnapToPos: pos: %s | tile_pos: %s | SelfPos: %s | MapPos: %s" % [pos, tile_pos, self.get_screen_center_position(), map.actor_tile_map.position])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not freeze:
		var dist = delta * speed
		if Input.is_key_pressed(KEY_W):
			self.offset.y -= dist
		if Input.is_key_pressed(KEY_S):
			self.offset.y += dist
		if Input.is_key_pressed(KEY_A):
			self.offset.x -= dist
		if Input.is_key_pressed(KEY_D):
			self.offset.x += dist
	if _touch_events.size() > 0:
		#if LOGGING: print(str(_touch_events))
		if _touch_events.size() == 1:
			var touch_events = _touch_events.values()[0]
			var drag_diff = touch_events['start'].position - touch_events['current'].position 
			self.position = _drag_start_camera_pos + (drag_diff / self.zoom)
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

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		var new_zoom = self.zoom
		if mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			new_zoom += Vector2(0.1, 0.1)
		if mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			new_zoom -= Vector2(0.1, 0.1)
		self.zoom = Vector2(max(1, new_zoom.x), max(1, new_zoom.y))

var _touch_events:Dictionary = {}
var _drag_start_camera_pos:Vector2
var _pinch_start_radius:float
var _pinch_last_radius:float
var _pinch_start_zoom:Vector2
func _unhandled_input(event: InputEvent) -> void:
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
		_touch_events[event.index]["current"] = event
		
