class_name CostEditControl
extends Control

@onready var premade_edit_entry:CostEditEntryControl = $VBoxContainer/CostEditEntryControl
@onready var entry_container = $VBoxContainer/ScrollContainer/FlowContainer
@onready var add_button:Button = $VBoxContainer/HBoxContainer/Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	premade_edit_entry.visible = false
	add_button.pressed.connect(create_new_entry)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func create_new_entry(key='', val=0):
	var new_entry:CostEditEntryControl = premade_edit_entry.duplicate()
	entry_container.add_child(new_entry)
	new_entry.visible = true
	new_entry.line_edit.text = key
	new_entry.spin_box.set_value_no_signal(val)
	#self.set_size(Vector2i(self.size.x, maxi(1,floori((entry_container.get_child_count()+1) / 2)) * 32 + 54))

func save_page_data():
	var data = {}
	for child:CostEditEntryControl in entry_container.get_children():
		if child.get_cost_key() != '':
			data[child.get_cost_key()] = child.get_cost_value()
	return data
	
func load_page_data(data):
	for child in entry_container.get_children():
		child.queue_free()
	for key in data.get('CostData', {}).keys():
		create_new_entry(key, data['CostData'][key])
		
