extends Node2D

@export var map_controller:MapControllerNode
@export var text_font:Font

var _refresh_time = 5
var _timer = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not self.visible:
		return
	_timer -= delta
	if _timer <= 0:
		queue_redraw()
		_timer = _refresh_time
		

func _draw() -> void:
	var game_state = CombatRootControl.Instance.GameState
	var actor_map = map_controller.actor_tile_map
	var players:Dictionary = {}
	var enemies:Array = []
	for actor:BaseActor in game_state.list_actors():
		if actor.is_player:
			players[actor.Id] = actor
		else:
			enemies.append(actor)
	
	for actor:BaseActor in enemies:
		var actor_pos = game_state.get_actor_pos(actor)
		var actor_coor = actor_map.map_to_local(actor_pos.to_vector2i())
		draw_circle(actor_coor,16.0, Color.RED, false, 2)
		for other_actor_id in actor.aggro.actor_id_to_threat:
			if not players.keys().has(other_actor_id):
				continue
			var other_actor_pos = game_state.get_actor_pos(other_actor_id)
			if not other_actor_pos:
				continue
			var other_actor_coor = actor_map.map_to_local(other_actor_pos.to_vector2i())
			draw_line(actor_coor, other_actor_coor, Color.RED, 2)
			if actor.aggro.current_aggroed_actor_id == other_actor_id:
				draw_dashed_line(actor_coor, other_actor_coor, Color.BLACK, 2)
			
			var mid_point = Vector2i((actor_coor.x + other_actor_coor.x)/2,(actor_coor.y + other_actor_coor.y)/2)
			var threat = actor.aggro.actor_id_to_threat[other_actor_id]
			mid_point.x -= 16
			var other_actor_color = StoryState.get_player_color(other_actor_id)
			draw_string(text_font, mid_point, str(threat), HORIZONTAL_ALIGNMENT_CENTER, -1, 12, other_actor_color)
