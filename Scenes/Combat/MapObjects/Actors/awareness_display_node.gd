class_name AwarenessDisplayNods
extends Node2D

@export var actor_node:BaseActorNode
@export var tile_map:TileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#_sync()
	pass

func _sync():
	var actor = actor_node.Actor
	if not CombatRootControl.Instance:
		return
	var actor_pos = CombatRootControl.Instance.GameState.get_actor_pos(actor)
	if !actor_pos:
		return
	for x in range(-1,2):
		for y in range(-1,2):
			var temp_pos = Vector2i(x, y)
			var rel_pos = MapHelper.rotate_relative_pos(temp_pos, actor_pos.dir)
			var pos = MapPos.new(actor_pos.x + rel_pos.x, actor_pos.y + rel_pos.y, actor_pos.z, actor_pos.dir)
			var dir = AttackHandler.get_relative_attack_direction(pos, actor_pos)
			if dir == AttackHandler.AttackDirection.Front:
				tile_map.set_cell(rel_pos, 0, Vector2i(0,1))
			if dir == AttackHandler.AttackDirection.Flank:
				tile_map.set_cell(rel_pos, 0, Vector2i(1,0))
			if dir == AttackHandler.AttackDirection.Back:
				tile_map.set_cell(rel_pos, 0, Vector2i(0,0))
			
		
