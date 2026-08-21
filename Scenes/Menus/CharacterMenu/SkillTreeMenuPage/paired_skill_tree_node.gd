class_name PairedSkillTreeNode
extends Control

signal node_button_down(skill_node_key:String, args:Dictionary)
signal node_button_up(skill_node_key:String, args:Dictionary)

@export var skill_node_1:SkillTreeNode
@export var skill_node_2:SkillTreeNode

var _skill_node_key:String

@export var skill_1_selected:bool = false
@export var grow_index:int = -1

func set_skill_node_data(data:Dictionary):
	_skill_node_key = data.get("SkillNodeKey")
	skill_node_1.set_skill_node_data(data, {"Index": 0})
	skill_node_2.set_skill_node_data(data, {"Index": 1})
	skill_node_1.node_button_down.connect(on_node_button_down)
	skill_node_1.node_button_up.connect(on_node_button_up)
	skill_node_2.node_button_down.connect(on_node_button_down)
	skill_node_2.node_button_up.connect(on_node_button_up)
	

func set_pages(pair_type:String, page_item_id_1, page_item_id_2):
	var node_1:SkillTreeNode = $Control/SkillTreeNode1
	var node_2:SkillTreeNode = $Control/SkillTreeNode2
	node_1.set_page(page_item_id_1)
	node_2.set_page(page_item_id_2)
	#if not node_1.button.pressed.is_connected(on_node_button_pressed):
		#node_1.button.button_down.connect(on_node_button_pressed.bind(0, true))
		#node_1.button.button_up.connect(on_node_button_pressed.bind(0, false))
		#node_2.button.button_down.connect(on_node_button_pressed.bind(1, true))
		#node_2.button.button_up.connect(on_node_button_pressed.bind(1, false))
	if pair_type.to_lower() == "or":
		$Control/AndIcon.hide()
		$Control/OrIcon.show()
	else:
		$Control/OrIcon.hide()
		$Control/AndIcon.show()

func set_unlock_state(pair_type:String, page_1_unlocked:bool, page_2_unlocked:bool, can_unlock_either):
	var node_1:SkillTreeNode = $Control/SkillTreeNode1
	var node_2:SkillTreeNode = $Control/SkillTreeNode2
	var can_unlock_1 = can_unlock_either
	var can_unlock_2 = can_unlock_either
	if pair_type.to_lower() == "or":
		if page_1_unlocked:
			can_unlock_2 = false
		if page_2_unlocked:
			can_unlock_1 = false
	if pair_type.to_lower() == "and":
		if page_1_unlocked:
			page_2_unlocked = true
		if page_2_unlocked:
			page_1_unlocked = true
	node_1.set_unlock_state(page_1_unlocked, can_unlock_1)
	node_2.set_unlock_state(page_2_unlocked, can_unlock_2)
	if page_1_unlocked:
		grow_index = 0
	elif page_2_unlocked:
		grow_index = 1
	else:
		grow_index = -1

func on_node_button_down(key, data):
	node_button_down.emit(key,data)

func on_node_button_up(key, data):
	node_button_up.emit(key,data)
	#if index == 0:
		#if down:
			#node_1_button_down.emit()
		#else:
			#node_1_button_up.emit()
	#if index == 1:
		#if down:
			#node_2_button_down.emit()
		#else:
			#node_2_button_up.emit()
