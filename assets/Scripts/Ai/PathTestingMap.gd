@tool
class_name PathTestingMap
extends TileMapLayer

@export var map_controller:MapControllerNode
@export var terrain_map:TileMapLayer
@export var test:bool =  false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if test:
		do_test()
		test = false
	pass

func do_test():
	self.clear()
	var map_data = map_controller.get_map_data()
	var game_state = GameStateData.new()
	game_state.MapState = MapStateData.new(game_state, map_data)
	
	#var star = AiHandler.build_path_finder(game_state)
	#for y in range(game_state.MapState.max_hight):
		#var line = ''
		#for x in range(game_state.MapState.max_width):
			#var pos = Vector2i(x,y)
			#var index = AiHandler._pos_to_index(pos, game_state)
			#
			#if star.has_point(index):
				#self.set_cell(pos, 0, Vector2i(2,0))
				#var connected = star.get_point_connections(index)
				#if connected.size() > 0:
					#self.set_cell(pos, 0, Vector2i(1,0))
			#else:
				#self.set_cell(pos, 0, Vector2i(0,0))
			#
		##print(line)
	
	var start_point = MapPos.new(5,5,0,0)
	var end_point = MapPos.new(7,3,0,0)
	var path_res = AiHandler.path_to_target(null, start_point, end_point, game_state)
	print("Found Path: %s to %s |  %s" % [start_point, end_point, path_res])
	for point:Vector2i in path_res['Path']:
		self.set_cell(point, 0, Vector2i(0,0))
