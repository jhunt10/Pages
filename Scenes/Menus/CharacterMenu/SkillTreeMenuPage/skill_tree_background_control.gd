class_name SkillTreeBackgroundControl
extends Control

@export var parent_control:SkillTreePageControl

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.queue_redraw()
	pass

func _draw() -> void:
	if !parent_control or not parent_control.tree_built:
		return
	#draw_rect(parent_control.get_rect(), Color.SLATE_GRAY)
	#draw_line(Vector2(0,0), get_local_mouse_position(), Color.BLACK, 5.0)
	var self_global_pos = self.get_global_rect().position
	var actor_color = parent_control._actor.get_title_page().get_player_color()
	for row in parent_control.tree_data:
		for node_data:Dictionary in row:
			var node = node_data.get("Node")
			if !node:
				continue
			var parent_id = node_data.get("ParentId")
			if parent_id:
				var parent_skill_node_data = parent_control.get_node_data_for_page_id(parent_id)
				if parent_skill_node_data.size() == 0:
					continue
				var parent_skill_node = parent_skill_node_data.get("Node")
				var node_rect = node.get_global_rect()
				var node_pos = node_rect.position - self_global_pos + (node_rect.size / 2)
				var parent_rect = parent_skill_node.get_global_rect()
				var parent_node_pos = parent_rect.position - self_global_pos + (parent_rect.size / 2)
				draw_line(node_pos, parent_node_pos, Color.BLACK, 10.0)
				if parent_skill_node_data.get("IsUnlocked"):
					draw_line(node_pos, parent_node_pos, actor_color, 5.0)
				else:
					draw_line(node_pos, parent_node_pos, Color.GRAY, 5.0)
