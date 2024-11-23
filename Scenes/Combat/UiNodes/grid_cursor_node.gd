class_name GridCursorNode
extends Sprite2D

enum Cursors {None, Default, Targeting}
var file_paths:Dictionary = {
	Cursors.Default: "res://assets/Sprites/UI/GridCursors/GridCursor_Default.png",
	Cursors.Targeting: "res://assets/Sprites/UI/GridCursors/GridCursor_Targeting.png"
}
var textures:Dictionary={}
var current_cur:Cursors
var current_spot:Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_cursor(Cursors.Default)
	pass # Replace with function body.

func set_cursor(cur:Cursors):
	current_cur = cur
	if cur == Cursors.None:
		self.texture = textures[Cursors.Default]
		self.visible = false
		_sync_position()
		return
	
	if !textures.has(cur):
		if !file_paths.has(cur):
			printerr("Unknown Cursor: " + str(cur))
			set_cursor(Cursors.None)
			return
		var loaded:Texture2D = load(file_paths[cur])
		textures[cur] = loaded
	
	if textures.has(cur):
		self.texture = textures[cur]
		self.visible = true
		_sync_position()
	else :
		printerr("Failed to find cursor: " + str(cur))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if current_cur == Cursors.None:
		return
	_sync_position()
	
func _sync_position():
	var map_controller = CombatRootControl.Instance.MapController
	if !map_controller or !map_controller.actor_tile_map:
		return
	var mouse_pos = map_controller.get_local_mouse_position()
	current_spot = map_controller.actor_tile_map.local_to_map(mouse_pos)
	self.position = map_controller.actor_tile_map.map_to_local(current_spot)
