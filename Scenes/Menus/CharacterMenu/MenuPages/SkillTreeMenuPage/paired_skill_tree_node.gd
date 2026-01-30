class_name PairedSkillTreeNode
extends Control

signal node_1_pressed
signal node_2_pressed

func set_pages(page_item_id_1, page_item_id_2):
	var node_1:SkillTreeNode = $SkillTreeNode1
	var node_2:SkillTreeNode = $SkillTreeNode2
	node_1.set_page(page_item_id_1)
	node_2.set_page(page_item_id_2)
	if not node_1.button.pressed.is_connected(on_node_button_pressed):
		node_1.button.pressed.connect(on_node_button_pressed.bind(0))
		node_2.button.pressed.connect(on_node_button_pressed.bind(1))

func set_unlock_state(pair_type:String, page_1_unlocked:bool, page_2_unlocked:bool, can_unlock_either):
	var node_1:SkillTreeNode = $SkillTreeNode1
	var node_2:SkillTreeNode = $SkillTreeNode2
	var can_unlock_1 = can_unlock_either
	var can_unlock_2 = can_unlock_either
	if pair_type.to_lower() == "or":
		if page_1_unlocked:
			can_unlock_2 = false
		if page_2_unlocked:
			can_unlock_1 = false
	node_1.set_unlock_state(page_1_unlocked, can_unlock_1)
	node_2.set_unlock_state(page_2_unlocked, can_unlock_2)

func on_node_button_pressed(index):
	if index == 0:
		node_1_pressed.emit()
	if index == 1:
		node_2_pressed.emit()
