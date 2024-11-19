@tool
extends TileMapLayer

@export var print_tiles:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if print_tiles:
		print_tiles = false
		print("Test2")
		var map_rect = get_used_rect()
		print("X: %s | Y: %s" % [map_rect.size.x, map_rect.size.y])
		for y in range(map_rect.size.y):
			var line = ""
			for x in range(map_rect.size.x):
				var val = self.get_cell_atlas_coords(Vector2i(x, y))
				var is_terrain = 0
				if val == Vector2i.ZERO:
					is_terrain = 1
				line += str(is_terrain) + "," 
			print(line.trim_suffix(","))
				
			
	pass
