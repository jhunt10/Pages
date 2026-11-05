@tool
class_name CharacterMenuTutorialControl
extends CombatTutorialControl

@export var left_page_tab_container:TabContainer
@export var equipment_container:Control
@export var page_book_slot:Control
@export var pages_tab:CharacterMenu_PagesTab

func _set_highlight_target():
		match highlight_target:
			HighlightTargets.None:
				highlight_node = null
				darken_screen = false
			HighlightTargets.ScriptInput: # Pages
				if left_page_tab_container:
					highlight_node = left_page_tab_container
					darken_screen = true
					left_page_tab_container.current_tab = 0
			HighlightTargets.QueInput: # Passives
				if left_page_tab_container:
					highlight_node = left_page_tab_container
					darken_screen = true
					left_page_tab_container.current_tab = 0
			HighlightTargets.Actions: # Actions
				if left_page_tab_container:
					highlight_node = left_page_tab_container
					darken_screen = true
					left_page_tab_container.current_tab = 0
			HighlightTargets.TurnOrder: # Supplies:
				if left_page_tab_container:
					highlight_node = left_page_tab_container
					darken_screen = true
					left_page_tab_container.current_tab = 1
			HighlightTargets.Gaps: # Equipment:
				if left_page_tab_container:
					left_page_tab_container.current_tab = 0
				if equipment_container:
					darken_screen = true
					highlight_node = equipment_container
			
			HighlightTargets.Objective: # Equipment:
				if left_page_tab_container:
					left_page_tab_container.current_tab = 0
				if equipment_container:
					darken_screen = true
					highlight_node = equipment_container

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	var done_tutorial = StoryState.get_story_flag("BookTutorialDone")
	if not done_tutorial:
		panel_index = 0
		current_tutorial = "Book"
	else:
		self.queue_free()
	
	for child in get_children():
		if child is ComPopContainer:
			child.confirmed.connect(_on_next)
			child.canceled.connect(_on_cancel)

func _on_cancel():
	self.queue_free()
	StoryState.set_story_flag("BookTutorialDone", true)

func _on_next():
	var old_panel = _get_current_pop_up()
	panel_index += 1
	var current_panel = _get_current_pop_up()
	
	if panel_index != 1 and old_panel and current_panel:
		var old_panel_bot_right = old_panel.position + old_panel.size
		var new_panel_pos = old_panel_bot_right - current_panel.size
		current_panel.safe_set_position(new_panel_pos)
	
	if current_panel.name == "End_ComPopContainer": 
		StoryState.set_story_flag("BookTutorialDone", true)
		self.queue_free()
	

func _draw_extra():
	if highlight_target == HighlightTargets.Objective:
		if page_book_slot:
			var rect = page_book_slot.get_global_rect()
			draw_rect(rect, Color.BLUE, false, 6)
	if (highlight_target == HighlightTargets.QueInput # Passives
		or highlight_target == HighlightTargets.Actions): 
			for page_slot:PageSlotButton in pages_tab.item_slot_buttons:
				var should_highlight = false
				if highlight_target == HighlightTargets.QueInput: # Passives
					should_highlight = page_slot.is_clipped
				elif highlight_target == HighlightTargets.Actions:
					should_highlight = !page_slot.is_clipped
				if should_highlight:
					var rect = page_slot.get_global_rect()
					draw_rect(rect, Color.BLUE, false, 3)
				
	pass
