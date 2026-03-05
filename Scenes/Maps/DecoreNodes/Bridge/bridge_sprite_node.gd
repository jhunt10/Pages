@tool
class_name BridgeSpriteNode
extends GateSpriteNode

func get_occupied_coors()->Array:
	var coors =[]
	var relative_poses = [
		[1,0],[2,0],[3,0],
		[1,1],[2,1],[3,1]
	]
	for rel in relative_poses:
		coors.append(Vector2i(map_coor.x + rel[0], map_coor.y + rel[1]))
	return coors
