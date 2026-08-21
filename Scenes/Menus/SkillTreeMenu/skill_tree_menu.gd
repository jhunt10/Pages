class_name SkillTreeMenu
extends Control


var premade_skill_node = preload("res://Scenes/Menus/SkillTreeMenu/skill_tree_node.tscn")
var premade_paired_skill_node = preload("res://Scenes/Menus/SkillTreeMenu/paired_skill_tree_node.tscn")

signal skill_menu_closed
# Signals for if connecting Character Menu
signal node_button_down(context, item_key, index, offset)
signal node_button_up(context, item_key, index, offset)

@export var title_args_label:Label
@export var close_button:TextureButton
@export var cancel_button:Button
@export var ok_button:Button
@export var background_panel:SkillTreeBackgroundPanel
@export var grid_main_container:HBoxContainer
@export var premade_column:VBoxContainer
@export var premade_spacer:HSeparator
@export var progress_bar:SkillTreeProgressBar
@export var unspent_points_label:Label
@export var spent_points_label:Label
@export var point_seperator_label:Label
@export var total_points_label:Label
@export var remaining_points_display:Control

@export var character_menu:CharacterMenu
@export var details_card_spawn_point:Node

var _actor:BaseActor
var tree_data:Array
var page_id_to_grid_mapping:Dictionary
var skill_node_key_to_grid_mapping:Dictionary
var tree_built:bool = false
var skill_page_items:Dictionary = {}
var max_unlocked_y_index:int = 0
# Skills player had when first entering menu
var _starting_skills:Dictionary = {}
# Working set of skills, doesn't apply until closing menu
var _unlocked_skills:Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	premade_column.hide()
	premade_spacer.hide()
	close_button.pressed.connect(close_menu)
	cancel_button.pressed.connect(close_menu)
	ok_button.pressed.connect(close_menu)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and _current_details_card:
		var mouse_event:InputEventMouseButton = event as InputEventMouseButton
		var mouse_pos = mouse_event.global_position
		if not mouse_event.pressed and not _current_details_card.get_global_rect().has_point(mouse_pos):
			_current_details_card.que_hide()


func set_actor(actor):
	_actor =  actor
	tree_built = false
	title_args_label.text = "-" + _actor.get_display_name().to_lower()
	background_panel.set_actor(_actor)
	if self.visible:
		sync(true)

func next_actor():
	var cur_index = StoryState.get_party_index_of_actor(_actor)
	var next_index = (cur_index +1) % 4
	var next_act = StoryState.get_party_actor_by_index(next_index)
	set_actor(next_act)
	pass

func close_menu():
	skill_menu_closed.emit()

func previous_actor():
	skill_menu_closed.emit()
	var cur_index = StoryState.get_party_index_of_actor(_actor)
	var next_index = (cur_index +3) % 4
	var next_act = StoryState.get_party_actor_by_index(next_index)
	set_actor(next_act)
	pass

func build_tree():
	self.tree_data = StoryState.get_skill_tree_data_for_actor(_actor)
	self._unlocked_skills = StoryState.get_unlocked_skills_for_actor(_actor)
	self._starting_skills = _unlocked_skills.duplicate()
	
	for child in premade_column.get_children():
		child.queue_free()
	for child in grid_main_container.get_children():
		if child == premade_column:
			continue
		if child == premade_spacer:
			continue
		child.queue_free()
	
	# Y & X assume top-bottom vertical layout
	# But doesn't really mater
	var y_index = 0
	for row in tree_data:
		var x_index = 0
		var new_row = premade_column.duplicate()
		if row.size() > 3:
			new_row.add_theme_constant_override('separation', 18)
		new_row.show()
		grid_main_container.add_child(new_row)
		for node_data in row:
			# Spacer
			if node_data.get("Spacer", false):
				var spacer = premade_spacer.duplicate()
				new_row.add_child(spacer)
				spacer.show()
				x_index += 1
				continue
			var new_node = null
			var skill_node_key = node_data.get("SkillNodeKey")
			var is_invalid = false
			if !skill_node_key:
				printerr("SkillTreeMenu.set_actor: SkillTreeNode missing SkillNodeKey at (%s, %s)"%[x_index, y_index])
				skill_node_key = node_data.get("PageKey", "") + "_Node"
				node_data['SkillNodeKey'] = skill_node_key
				is_invalid = true
			skill_node_key_to_grid_mapping[skill_node_key] = [x_index, y_index]
			# Paired Nodes
			if node_data.keys().has("PairType"):
				new_node = premade_paired_skill_node.instantiate()
			else:
				new_node = premade_skill_node.instantiate()
			if not new_node:
				continue
			new_node.set_skill_node_data(node_data)
			new_node.node_button_down.connect(on_node_button_down)
			new_node.node_button_up.connect(on_node_button_up)
			new_row.add_child(new_node)
			#new_row.add_child(new_node)
			new_node.show()
			node_data['Node'] = new_node
			# Add child to parent node
			if node_data.keys().has("ParentSkillKey"):
				var parent = node_data['ParentSkillKey']
				var parent_node_data = get_node_data_for_skill_node(parent)
				if not parent_node_data.keys().has("Children"):
					parent_node_data['Children'] = []
				parent_node_data['Children'].append(skill_node_key)
			if is_invalid and new_node and not (new_node is PairedSkillTreeNode):
				new_node.invalid_icon.show()
			x_index += 1
		#new_row.show()
		y_index += 1
	#for child in color_rec_spacers:
		#grid_container.add_child(child)
	tree_built = true
	#background_control.queue_redraw()

func sync(skip_animations:bool=false):
	if not tree_built:
		build_tree()
	var total_title_points:int = _actor.get_level() - 1
	var spent_points:int = _unlocked_skills.size()
	total_points_label.text = str(total_title_points)
	# Can't use _actor.get_unspent_skill_points since actor might not be synced  
	var remaining_points:int = total_title_points - spent_points 
	
	spent_points_label.text = str(spent_points)
	if spent_points != total_title_points:
		spent_points_label.show()
		point_seperator_label.show()
	else:
		spent_points_label.hide()
		point_seperator_label.hide()
	
	if skip_animations:
		background_panel.set_background_progresss(spent_points, total_title_points)
	
		
		
	unspent_points_label.text = str(remaining_points)
	if remaining_points == 0:
		remaining_points_display.hide()
	else:
		remaining_points_display.show()
	max_unlocked_y_index = 0
	var y_index = 0
	for row in tree_data:
		for node_data in row:
			var skill_node_key = node_data.get("SkillNodeKey", "")
			# Paired Nodes
			if node_data.keys().has("PairType"):
				var unlock_data = _unlocked_skills.get(skill_node_key, {})
				var p1_is_unlocked = unlock_data.get("Index", -1) == 0
				var p2_is_unlocked =  unlock_data.get("Index", -1) == 1
				if node_data.get("AlwaysUnlocked", false):
					p1_is_unlocked = true
					p2_is_unlocked = true
				var can_unlock_either = y_index-1 <= spent_points and remaining_points > 0
				var paired_skill_node:PairedSkillTreeNode = node_data.get("Node")
				if paired_skill_node:
					paired_skill_node.set_unlock_state(node_data.get("PairType"), p1_is_unlocked, p2_is_unlocked, can_unlock_either)
				node_data['IsUnlocked'] = p1_is_unlocked or p2_is_unlocked
				node_data['P1IsUnlocked'] = p1_is_unlocked
				node_data['P2IsUnlocked'] = p2_is_unlocked
				node_data['CanUnlock'] = can_unlock_either
			# Single Node
			else:
				var is_unlocked = (_unlocked_skills.keys().has(skill_node_key) or node_data.get("AlwaysUnlocked", false) )
				var can_unlock = y_index-1 <= spent_points and remaining_points > 0
				var parent_id = node_data.get("ParentSkillKey")
				if parent_id and not _unlocked_skills.keys().has(parent_id):
					can_unlock = false
				var skill_node:SkillTreeNode = node_data.get("Node")
				if skill_node:
					#print("SkillTreeMenu: %s: %s | Is:%s     Can:%s" %[[x_index, y_index], page_item_id, is_unlocked, can_unlock])
					skill_node.set_unlock_state(is_unlocked, can_unlock)
				node_data['IsUnlocked'] = is_unlocked
				node_data['CanUnlock'] = can_unlock
				if is_unlocked:
					max_unlocked_y_index = max(y_index, max_unlocked_y_index)
		y_index += 1
	progress_bar.set_progresss(spent_points, y_index-1)
	
	#background_control.queue_redraw()

func get_node_data_for_page_id(page_id:String)->Dictionary:
	var indexes = page_id_to_grid_mapping.get(page_id, null)
	if !indexes:
		return {}
	if tree_data.size() > indexes[1] and tree_data[indexes[1]].size() > indexes[0]:
		var data = tree_data[indexes[1]][indexes[0]]
		return data
	return {}

func get_node_data_for_skill_node(skill_node_key:String)->Dictionary:
	var indexes = skill_node_key_to_grid_mapping.get(skill_node_key, null)
	if !indexes:
		return {}
	if tree_data.size() > indexes[1] and tree_data[indexes[1]].size() > indexes[0]:
		var data = tree_data[indexes[1]][indexes[0]]
		return data
	return {}

func get_page_key_if_unlocked(skill_node_key, args):
	var node_data = get_node_data_for_skill_node(skill_node_key)
	var page_key = node_data.get("PageKey", null)
	var is_unlocked = _unlocked_skills.has(skill_node_key)  or node_data.get("AlwaysUnlocked")
	# Paired Node extra logic
	if node_data.keys().has("PairType"):
		var sub_pages:Array = node_data.get("Pages", [])
		var index = args.get("Index", -1)
		if index < 0 or sub_pages.size() < index:
			printerr("SkillTreeMenu on_node_button_down: Invalid Index [%s,%s]" %[skill_node_key, args])
			return null
		page_key = node_data.get("Pages", [])[args.get("Index")]
		is_unlocked = _unlocked_skills.get(skill_node_key, {}).get("Index", -2) == index or node_data.get("AlwaysUnlocked")
	if is_unlocked:
		return page_key
	return null

func on_node_button_down(skill_node_key, args):
	var node_data = get_node_data_for_skill_node(skill_node_key)
	var page_key = get_page_key_if_unlocked(skill_node_key, args)
	if page_key:
		node_button_down.emit("SkillTree", page_key, 0, Vector2.ZERO)

func on_node_button_up(skill_node_key, args):
	var node_data = get_node_data_for_skill_node(skill_node_key)
	var page_key = node_data.get("PageKey")
	if args.has("Index"):
		page_key = node_data.get("Pages", [])[args.get("Index")]
	if !page_key:
		printerr("SkillTreeMenu on_node_button_down: Failed to find Page Key for node at [%s,%s]" %[skill_node_key, args])
		return
	var page_item = ItemLibrary.get_static_inst_of_item(page_key)
	
	var  was_dragging = character_menu._dragging
	node_button_up.emit("SkillTree", page_key, 0)
	if was_dragging:
		return
	
	var confirm_text = "-LOCKED-"
	var disabled = true
	var is_unlocked = _unlocked_skills.keys().has(skill_node_key)  or node_data.get("AlwaysUnlocked")
	# Paired Node
	if node_data.keys().has("PairType"):
		var sub_pages:Array = node_data.get("Pages", [])
		var index = args.get("Index", -1)
		if sub_pages.size() < index:
			printerr("SkillTreeMenu on_node_button_down: Invalid Index [%s,%s]" %[skill_node_key, args])
			return
		page_key = node_data.get("Pages", [])[args.get("Index")]
		var unlocked_index = _unlocked_skills.get(skill_node_key, {}).get("Index", -2)
		if unlocked_index == -2: # not unlocked
			is_unlocked = false
		elif unlocked_index == index:
			is_unlocked = true
		else:
			is_unlocked = false
			confirm_text = "Swap"
			disabled = false
	
	
	# Always Unlocked
	if node_data.get("AlwaysUnlocked", false):
		confirm_text = "" # Hide Button
	# Is Unlocked
	elif is_unlocked:
		# Determine if can refund
		var can_refund = true
		var indexes = skill_node_key_to_grid_mapping.get(skill_node_key, null)
		var x_index = indexes[0]
		var y_index = indexes[1]
		if node_data.has("Children"):
			for child_key in node_data['Children']:
				if _unlocked_skills.keys().has(child_key):
					can_refund = false
		# If this node isn't on the last unlocked row, 
		#    check if refunding it will invalidate other nodes
		if indexes[1] < max_unlocked_y_index:
			var only_skill_in_row = true
			for check_x_index in tree_data[y_index].size():
				if check_x_index ==  x_index:
					continue
				if tree_data[y_index][check_x_index].get("IsUnlocked", false):
					only_skill_in_row = false
					break
			if only_skill_in_row:
				can_refund = false
		
		if can_refund:
			confirm_text = "Refund" 
			disabled = false
		else:
			confirm_text = "Can't Refund" 
			disabled = true
	elif node_data.get("CanUnlock"):
		confirm_text = "Unlock"
		disabled = false
	if Input.is_key_pressed(KEY_CTRL):
		on_node_confirmed(page_item, skill_node_key, args)
	else:
		var detail_card = create_details_card(
			page_item, 
			on_node_confirmed.bind(skill_node_key, args),
			confirm_text, 
			disabled
		)

func on_node_confirmed(_item:BaseItem, skill_node_key, args={}):
	var node_data = get_node_data_for_skill_node(skill_node_key)
	var node_key = node_data.get("SkillNodeKey", "")
	if _unlocked_skills.keys().has(skill_node_key):
		#if node_data.keys().has("PairType"):
			#var unlocked_index = node_data.get("Index", -1)
			#var selected_index = args.get("Index", -1)
			#if unlocked_index != selected_index:
				#transaction type should just be passed in args
		_unlocked_skills.erase(skill_node_key)
	elif node_key != '':
		_unlocked_skills[skill_node_key] = args
	if _current_details_card:
		_current_details_card.start_hide()
	sync()
	apply_changes()
	unspent_points_label.text = str(_actor.get_unspent_skill_points())
	_actor.stats_changed.emit()

func apply_changes():
	#var unlocked_skills = []
	#for row in tree_data:
		#for node_data in row:
			#if node_data.keys().has("PairType"):
				#if node_data.get("P1IsUnlocked"):
					#unlocked_skills.append(node_data.get("PageItemId1"))
				#if node_data.get("P2IsUnlocked"):
					#unlocked_skills.append(node_data.get("PageItemId2"))
			#else:
				#if node_data.get("IsUnlocked"):
					#unlocked_skills.append(node_data.get("PageItemId"))
	StoryState.set_unlocked_skills_for_actor(_actor, _unlocked_skills)

func get_has_changes()->bool:
	if _unlocked_skills.size() != _starting_skills.size():
		return true
	for page_key in _unlocked_skills:
		if not _starting_skills.has(page_key):
			return true
	return false
	
var _current_details_card
func create_details_card(
		item:BaseItem, 
		on_confirm:Callable,
		confirm_button_text:String="Confirm",  
		disable_confirm:bool=false
		)->ItemDetailsCard:
	var old_detail_card
	if _current_details_card:
		old_detail_card = _current_details_card
		# Same Item is already beging displayed
		if old_detail_card.item_id == item.Id:
			return old_detail_card
		if old_detail_card.state != ItemDetailsCard.States.Hidden:
			old_detail_card.start_hide()
	
	if !item:
		return null
	_current_details_card = null
	_current_details_card = load("res://Scenes/Menus/CharacterMenu_old/MenuPages/ItemDetailsCard/item_details_card.tscn").instantiate()
	
	var spawn_point = details_card_spawn_point
	if character_menu:
		spawn_point = character_menu.details_card_spawn_point
	
	spawn_point.add_child(_current_details_card)
	if old_detail_card:
		spawn_point.remove_child(old_detail_card)
		spawn_point.add_child(old_detail_card)
	_current_details_card.vertical = true
	#_current_details_card.hide_done.connect(_on_details_card_freed)
	_current_details_card.set_detail_card_item(null, item, confirm_button_text, disable_confirm)
	_current_details_card.item_confirmed.connect(on_confirm)
	_current_details_card.start_show()
	return _current_details_card
