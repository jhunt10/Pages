class_name SubActionsEditControl
extends Control

@onready var subactions_container:VBoxContainer = $VBoxContainer/ScrollContainer/VBoxContainer
@onready var premade_subaction_entry:SubActionEntryControl = $VBoxContainer/SubActionEntry
@onready var add_button:Button = $VBoxContainer/HBoxContainer/Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	premade_subaction_entry.visible = false
	add_button.pressed.connect(on_add_button)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func lose_focus_if_has():
	for sub in subactions_container.get_children():
		sub.lose_focus_if_has()

func get_sub_action_tags()->Array:
	var out_list = []
	for sub:SubActionEntryControl in subactions_container.get_children():
		var sub_action:BaseSubAction = ActionLibary.get_sub_action_script(sub.real_script)
		var subact_data = sub.save_page_data()
		var tags = sub_action.get_action_tags(subact_data)
		for tag in tags:
			if not out_list.has(tag):
				out_list.append(tag)
	return out_list

func on_add_button():
	create_new_entry(0)

func create_new_entry(frame:int, data:Dictionary = {}):
	var new_entry:SubActionEntryControl = premade_subaction_entry.duplicate()
	subactions_container.add_child(new_entry)
	new_entry.visible = true
	new_entry.load_subaction_data(frame, data)
	new_entry.index_changed.connect(order_sub_actions)
	order_sub_actions()
	pass

func load_page_data(data:Dictionary):
	for sub in subactions_container.get_children():
		sub.queue_free()
	var subaction_datas = data.get('SubActions', {})
	for index in range(24):
		if subaction_datas.get(str(index), '') is Dictionary:
			create_new_entry(index, subaction_datas[str(index)])
		if subaction_datas.get(str(index), '') is Array:
			for subsub in subaction_datas[str(index)]:
				create_new_entry(index, subsub)
			
func save_page_data()->Dictionary:
	var dict = {}
	for index in range(ActionQueController.FRAMES_PER_ACTION):
		var list = []
		for sub:SubActionEntryControl in subactions_container.get_children():
			if sub.index_input.value == index:
				list.append(sub.save_page_data())
		if list.size() > 0:
			dict[str(index)] = list
	return dict
	
func order_sub_actions():
	var temp_list = []
	for sub:SubActionEntryControl in subactions_container.get_children():
		subactions_container.remove_child(sub)
		temp_list.append(sub)
	for index in range(ActionQueController.FRAMES_PER_ACTION):
		for entry:SubActionEntryControl in temp_list:
			if entry.index_input.value == index:
				subactions_container.add_child(entry)
