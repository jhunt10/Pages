@tool
class_name CombatTutorialControl
extends Control

enum HighlightTargets {None, Actions, ScriptInput, QueInput, TurnOrder, Gaps, Deploy}

@export var highlight_target:HighlightTargets:
	set(val):
		highlight_target = val
		match highlight_target:
			HighlightTargets.None:
				highlight_node = null
				darken_screen = false
			HighlightTargets.Actions:
				if que_input_contol:
					highlight_node = que_input_contol.get_node("QueInputBackPatchContainer")
					darken_screen = true
			HighlightTargets.ScriptInput:
				if que_input_contol:
					highlight_node = que_input_contol.que_display_control
					darken_screen = true
			HighlightTargets.QueInput:
				if que_input_contol:
					highlight_node = que_input_contol
					darken_screen = true
			HighlightTargets.TurnOrder:
				if combat_panel:
					highlight_node = combat_panel.turns_container
					darken_screen = true
			HighlightTargets.Gaps:
				if combat_panel:
					highlight_node = combat_panel.turns_container
					darken_screen = true
@export var darken_screen:bool
@export var highlight_node:Control

@export var que_input_contol:QueInputControl
@export var combat_panel:CombatControlPanel

@export var panel_index:int:
	set(val):
		var children = get_children()
		var child_count = children.size()
		if child_count == 0:
			panel_index = 0
		else:
			panel_index = (val + child_count) % child_count
		var current_child:ComPopContainer = null
		for child_index in range(child_count):
			var child = children[child_index]
			if child is ComPopContainer:
				child.visible = child_index == panel_index
				if child_index == panel_index:
					current_child = child
		if current_child:
			print(current_child.name)
			highlight_target = current_child.highlight_target
			print("SetHighlight Target: " +  str(highlight_target))
		self.queue_redraw()
		
		#if panel_index >= 0 and highlight_arr.size() < panel_index:
			#highlight_target = highlight_arr[panel_index]
		#else:
			#highlight_target = HighlightTargets.None

var highlight_arr:Array = [
	HighlightTargets.None, # Question
	HighlightTargets.Actions, # Actions
	HighlightTargets.ScriptInput, # Script
	HighlightTargets.ScriptInput, # APR
	HighlightTargets.QueInput, # Script Input
	HighlightTargets.QueInput, # Script Submit
	HighlightTargets.TurnOrder
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	var done_tutorial = StoryState.get_story_flag("TutorialDone")
	if done_tutorial:
		self.queue_free()
		return
	
	for child in get_children():
		if child is ComPopContainer:
			child.confirmed.connect(_on_next)
			child.canceled.connect(_on_cancel)
	
	CombatRootControl.Instance.QueController.execution_active.connect(_on_round_start)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if pause_round:
		pause_round = false
		paused_before = true
		CombatRootControl.pause_combat()
		self.show()
	pass

var pause_round = false
var paused_before = false
func _on_round_start():
	if not paused_before:
		pause_round = true
		paused_before = true

func _on_cancel():
	self.hide()
	StoryState.set_story_flag("TutorialDone", true)

func _on_next():
	panel_index += 1
	var current_panel = _get_current_pop_up()
	if current_panel.name == "RoundStart_ComPopContainer": # Wait for input
		self.hide()
	if current_panel.name == "End_ComPopContainer": # Gaps2
		_on_last_card()
		CombatRootControl.resume_combat()

func _on_last_card():
	self.queue_free()
	StoryState.set_story_flag("TutorialDone", true)

func _get_current_pop_up()->ComPopContainer:
	var children = get_children()
	if panel_index >= 0 and panel_index < children.size():
		if children[panel_index] is ComPopContainer:
			return children[panel_index]
	return null

func _draw() -> void:
	if darken_screen:
		var darken_color = Color(0,0,0,0.5)
		var boarder = 5
		if highlight_node:
			var node_space = highlight_node.get_global_rect()
			# Left side
			draw_rect(Rect2(0,0, node_space.position.x - boarder, self.size.y), darken_color)
			# Right Side
			draw_rect(Rect2(node_space.position.x + node_space.size.x + boarder,0, 
				self.size.x - node_space.position.x - node_space.size.x + (2*boarder), self.size.y), darken_color)
			# Top Middle
			draw_rect(Rect2(node_space.position.x - boarder,0, node_space.size.x + (2*boarder), node_space.position.y - boarder), darken_color)
			# Bottom Middle
			draw_rect(Rect2(node_space.position.x - boarder, node_space.position.y + node_space.size.y + boarder, 
				node_space.size.x + (2*boarder), self.size.y - node_space.position.y - node_space.size.y), darken_color)
			
			# Outline
			draw_rect(Rect2(node_space.position.x - boarder, node_space.position.y - boarder, 
			node_space.size.x + boarder + boarder, node_space.size.y + boarder + boarder), Color.RED, false, 3)
		else:
			draw_rect(self.get_global_rect(), darken_color)
	if not Engine.is_editor_hint():
		if highlight_target == HighlightTargets.Gaps:
			_highlight_gaps()

func _highlight_gaps():
	var que_collection:QueCollectionControl = CombatRootControl.Instance.ui_control.combat_control_panel.turns_container
	for que:QueCollection_QueDisplayContainer in que_collection._ques.values():
		for slot:QueMiniSlotIcon in que._slots:
			if slot.is_gap:
				var rect = slot.get_global_rect()
				draw_rect(rect, Color.BLUE, false, 6)
