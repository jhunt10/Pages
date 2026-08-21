class_name SkillTreeBackgroundPanel
extends PanelContainer

const DefaultBGColor = Color("999999")
const SoldierBGColor = Color("4F87AF")
const RogueBGColor = Color("85A385")
const PriestBGColor = Color("FFEDA0")
const MageBGColor = Color("E08686")

@export var parent_control:SkillTreeMenu
@export var background_fill_speed:int = 200
var _target_background_fill_x:int
var _current_background_fill_x:int

var background_fill_color = SoldierBGColor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if abs(_current_background_fill_x - _target_background_fill_x) > 0.1:
		var change = delta * background_fill_speed
		if _current_background_fill_x > _target_background_fill_x:
			_current_background_fill_x = max(_target_background_fill_x, _current_background_fill_x - change)
		else:
			_current_background_fill_x = min(_target_background_fill_x, _current_background_fill_x + change)
	self.queue_redraw()
	pass

func _draw() -> void:
	if !parent_control or not parent_control.tree_built:
		return
	
	
	 #Progress Fill Background
	var unlocked_count = parent_control._unlocked_skills.size() + 1
	#var column_count = parent_control.tree_data.size()
	#var percent_full = minf(unlocked_count+1, column_count) / (column_count as float)
	#_target_background_fill_x = round(self.size.x * percent_full)
	draw_rect(Rect2(0,0,_current_background_fill_x, self.size.y), background_fill_color)
	
	# Dashed lines between columns
	#var column_count = 0
	var last_x = -1
	var index = -1
	for col in parent_control.grid_main_container.get_children():
		if col is VBoxContainer:
			if not col.visible:
				continue
			index += 1
			#print(col.global_position.x)
			if last_x > 0:
				var mid_x = ((col.global_position.x - self.global_position.x + last_x) / 2.0)
				var top = Vector2(mid_x, 0)
				var bot = Vector2(mid_x, self.size.y)
				if mid_x < _current_background_fill_x:
					draw_dashed_line(top, bot, DefaultBGColor, 2, 6)
				else:
					draw_dashed_line(top, bot, background_fill_color, 2, 6)
				
				if index-1 == unlocked_count:
					_target_background_fill_x = mid_x
			last_x = col.global_position.x + col.size.x - self.global_position.x
	if index-1 < unlocked_count:
		_target_background_fill_x = (self.size.x as float)
	
	# Draw Lines between nodes
	var self_global_pos = self.get_global_rect().position
	var actor_color = parent_control._actor.get_title_page().get_player_color()
	for row in parent_control.tree_data:
		for node_data:Dictionary in row:
			var node = node_data.get("Node")
			if !node:
				continue
			var parent_key = node_data.get("ParentSkillKey")
			if parent_key:
				var parent_skill_node_data = parent_control.get_node_data_for_skill_node(parent_key)
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

func set_actor(actor:BaseActor):
	var actor_key = actor.ActorKey
	match actor_key:
		"SoldierTemplate":
			background_fill_color = SoldierBGColor
		"RogueTemplate":
			background_fill_color = RogueBGColor
		"PriestTemplate":
			background_fill_color = PriestBGColor
		"MageTemplate":
			background_fill_color = MageBGColor

func set_background_progresss(value:int, total:int):
	var percent_full = minf(value+2, total+1) / ((total+1) as float)
	_target_background_fill_x = round(self.size.x * percent_full)
	_current_background_fill_x = _target_background_fill_x
