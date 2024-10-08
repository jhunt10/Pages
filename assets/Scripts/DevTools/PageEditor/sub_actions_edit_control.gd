class_name SubActionsEditControl
extends Control

@onready var subactions_container:VBoxContainer = $VBoxContainer/ScrollContainer/VBoxContainer
@onready var premade_subaction_entry:SubActionEntryControl = $VBoxContainer/ScrollContainer/VBoxContainer/SubActionEntry
@onready var add_button:Button = $VBoxContainer/HBoxContainer/Button

var subaction_entries:Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	premade_subaction_entry.visible = false
	add_button.pressed.connect(on_add_button)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func lose_focus_if_has():
	for sub in subaction_entries:
		sub.lose_focus_if_has()

func on_add_button():
	create_new_entry(0)

func create_new_entry(frame:int, data:Dictionary = {}):
	var new_entry:SubActionEntryControl = premade_subaction_entry.duplicate()
	subactions_container.add_child(new_entry)
	new_entry.visible = true
	new_entry.load_subaction_data(frame, data)
	subaction_entries.append(new_entry)
	new_entry.index_changed.connect(order_sub_actions)
	order_sub_actions()
	pass

func load_page_data(data:Dictionary):
	for sub in subaction_entries:
		sub.queue_free()
	subaction_entries.clear()
	var subaction_datas = data.get('SubActions', {})
	for index in range(24):
		if subaction_datas.get(str(index), '') is Dictionary:
			create_new_entry(index, subaction_datas[str(index)])
		if subaction_datas.get(str(index), '') is Array:
			for subsub in subaction_datas[str(index)]:
				create_new_entry(index, subsub)
			
func save_page_data()->Dictionary:
	var dict = {}
	for index in range(QueControllerNode.FRAMES_PER_ACTION):
		var list = []
		for sub:SubActionEntryControl in subaction_entries:
			if sub.index_input.value == index:
				list.append(sub.save_page_data())
		if list.size() > 0:
			dict[str(index)] = list
	return dict
	
func order_sub_actions():
	for entry in subaction_entries:
		subactions_container.remove_child(entry)
	for index in range(QueControllerNode.FRAMES_PER_ACTION):
		for entry:SubActionEntryControl in subaction_entries:
			if entry.index_input.value == index:
				subactions_container.add_child(entry)
