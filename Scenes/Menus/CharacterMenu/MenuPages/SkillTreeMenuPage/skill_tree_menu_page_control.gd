class_name SkillTreePageControl
extends Control

@export var character_menu:CharacterMenuControl
@export var scroll_bar:CustScrollBar
@export var background_control:Control
@export var tree_container:BoxContainer
@export var row_prefab:HBoxContainer
@export var grid_container:GridContainer
@export var skill_node_prefab:SkillTreeNode
@export var paired_node_prefab:PairedSkillTreeNode

@export var unspent_points_label:Label
@export var total_points_label:Label

var _actor:BaseActor
var tree_data:Array
var page_id_to_grid_mapping:Dictionary
var tree_built:bool = false
var skill_page_items:Dictionary = {}
var max_unlocked_y_index:int = 0
# Skills player had when first entering menu
var _starting_skills:Array = []
# Working set of skills, doesn't apply until closing menu
var _unlocked_skills:Array = []

func set_actor(actor):
	_actor =  actor
	# Clean up
	var color_rec_spacers = []
	for child in grid_container.get_children():
		if child != row_prefab and child != background_control:
			# Dumb hack to control spacing
			if child is ColorRect:
				color_rec_spacers.append(child)
				grid_container.remove_child(child)
			else:
				child.queue_free()
	row_prefab.hide()
	skill_node_prefab.hide()
	paired_node_prefab.hide()
	
	self.tree_data = StoryState.get_skill_tree_data_for_actor(actor)
	self._unlocked_skills = StoryState.get_unlocked_skills_for_actor(actor, false)
	self._starting_skills = _unlocked_skills.duplicate()
	var y_index = 0
	for row in tree_data:
		var x_index = 0
		#var new_row = row_prefab.duplicate()
		#tree_container.add_child(new_row)
		for node_data in row:
			var new_node = null
			# Paired Nodes
			if node_data.keys().has("PairType"):
				new_node = paired_node_prefab.duplicate()
				var pair_type = node_data['PairType']
				var page_item_id_1 = node_data.get("PageItemId1")
				var page_item_id_2 = node_data.get("PageItemId2")
				new_node.set_pages(pair_type, page_item_id_1, page_item_id_2)
				new_node.node_1_pressed.connect(on_node_clicked.bind(page_item_id_1))
				new_node.node_2_pressed.connect(on_node_clicked.bind(page_item_id_2))
				page_id_to_grid_mapping[page_item_id_1] = [x_index, y_index]
				page_id_to_grid_mapping[page_item_id_2] = [x_index, y_index]
			else:
				new_node = skill_node_prefab.duplicate()
				var page_item_id = node_data.get("PageItemId")
				new_node.set_page(page_item_id)
				new_node.button.pressed.connect(on_node_clicked.bind(page_item_id))
				page_id_to_grid_mapping[page_item_id] = [x_index, y_index]
			if not new_node:
				continue
			grid_container.add_child(new_node)
			#new_row.add_child(new_node)
			new_node.show()
			node_data['Node'] = new_node
			x_index += 1
		#new_row.show()
		y_index += 1
	for child in color_rec_spacers:
		grid_container.add_child(child)
	tree_built = true
	sync_skill_nodes_states()
	background_control.queue_redraw()
	scroll_bar._delay_size_calc = true

func sync_skill_nodes_states():
	var points_to_spend = 10 + _actor.stats.get_stat(StatHelper.Level, 0)
	var spent_points = _unlocked_skills.size()
	total_points_label.text = str(points_to_spend)
	var remaining_points = points_to_spend - spent_points
	unspent_points_label.text = str(remaining_points)
	scroll_bar.calc_bar_size()
	max_unlocked_y_index = 0
	var y_index = 0
	for row in tree_data:
		var x_index = 0
		for node_data in row:
			# Paired Nodes
			if node_data.keys().has("PairType"):
				var page_item_id_1 = node_data.get("PageItemId1")
				var page_item_id_2 = node_data.get("PageItemId2")
				var p1_is_unlocked = _unlocked_skills.has(page_item_id_1)  or node_data.get("AlwaysUnlocked", false)
				var p2_is_unlocked = _unlocked_skills.has(page_item_id_2) or node_data.get("AlwaysUnlocked", false)
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
				var page_item_id = node_data.get("PageItemId")
				var is_unlocked = (_unlocked_skills.has(page_item_id) or node_data.get("AlwaysUnlocked", false) )
				var can_unlock = y_index-1 <= spent_points and remaining_points > 0
				var parent_id = node_data.get("ParentId")
				if parent_id and not _unlocked_skills.has(parent_id):
					can_unlock = false
				var skill_node:SkillTreeNode = node_data.get("Node")
				if skill_node:
					#print("SkillTreeMenu: %s: %s | Is:%s     Can:%s" %[[x_index, y_index], page_item_id, is_unlocked, can_unlock])
					skill_node.set_unlock_state(is_unlocked, can_unlock)
				node_data['IsUnlocked'] = is_unlocked
				node_data['CanUnlock'] = can_unlock
				if is_unlocked:
					max_unlocked_y_index = max(y_index, max_unlocked_y_index)
			x_index += 1
		y_index += 1
	background_control.queue_redraw()

func get_node_data_for_page_id(page_id:String)->Dictionary:
	var indexes = page_id_to_grid_mapping.get(page_id, null)
	if !indexes:
		return {}
	if tree_data.size() > indexes[1] and tree_data[indexes[1]].size() > indexes[0]:
		var data = tree_data[indexes[1]][indexes[0]]
		return data
	return {}

func on_node_clicked(page_id):
	var page_item = ItemLibrary.get_static_inst_of_item(page_id)
	var node_data = get_node_data_for_page_id(page_id)
	var confirm_text = "-LOCKED-"
	var disabled = true
	var is_unlocked = false
	# Paired Node
	if node_data.keys().has("PairType"):
		if node_data.get("PageItemId1") == page_id:
			is_unlocked = node_data.get("P1IsUnlocked")
		else:
			is_unlocked = node_data.get("P2IsUnlocked")
	# Single Node
	else:
		is_unlocked = node_data.get("IsUnlocked")
	
	
	# Always Unlocked
	if node_data.get("AlwaysUnlocked", false):
		confirm_text = "" # Hide Button
	# Is Unlocked
	elif is_unlocked:
		# Determine if can refund
		var can_refund = true
		var indexes = page_id_to_grid_mapping.get(page_id, null)
		var x_index = indexes[0]
		var y_index = indexes[1]
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
			confirm_text = "-LOCKED-" 
			disabled = true
	elif node_data.get("CanUnlock"):
		confirm_text = "Unlock"
		disabled = false
	var detail_card = character_menu.create_details_card(page_item, confirm_text, true, disabled)
	if not detail_card.item_confirmed.is_connected(on_node_confirmed):
		detail_card.item_confirmed.connect(on_node_confirmed)

func on_node_confirmed(item:BaseItem):
	var node_data = get_node_data_for_page_id(item.ItemKey)
	if _unlocked_skills.has(item.ItemKey):
		_unlocked_skills.erase(item.ItemKey)
	else:
		_unlocked_skills.append(item.ItemKey)
	character_menu._current_details_card.start_hide()
	sync_skill_nodes_states()

func apply_changes():
	var unlocked_skills = []
	for row in tree_data:
		for node_data in row:
			if node_data.keys().has("PairType"):
				if node_data.get("P1IsUnlocked"):
					unlocked_skills.append(node_data.get("PageItemId1"))
				if node_data.get("P2IsUnlocked"):
					unlocked_skills.append(node_data.get("PageItemId2"))
			else:
				if node_data.get("IsUnlocked"):
					unlocked_skills.append(node_data.get("PageItemId"))
	StoryState.set_unlocked_skill_for_actor(_actor, unlocked_skills)

func get_has_changes()->bool:
	if _unlocked_skills.size() != _starting_skills.size():
		return true
	for page_key in _unlocked_skills:
		if not _starting_skills.has(page_key):
			return true
	return false
	
