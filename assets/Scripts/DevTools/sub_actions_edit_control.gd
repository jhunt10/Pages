class_name SubActionsEditControl
extends Control

@onready var subactions_container:VBoxContainer = $VBoxContainer/ScrollContainer/VBoxContainer
@onready var premade_subaction_entry:SubActionEntryControl = $VBoxContainer/ScrollContainer/VBoxContainer/SubActionEntry

var subaction_entries:Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	premade_subaction_entry.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func create_new_entry(frame:int, data:Dictionary = {}):
	var new_entry:SubActionEntryControl = premade_subaction_entry.duplicate()
	subactions_container.add_child(new_entry)
	new_entry.visible = true
	new_entry.load_subaction_data(frame, data)
	subaction_entries.append(new_entry)
	pass

func load_page_data(data:Dictionary):
	for sub in subaction_entries:
		sub.queue_free()
	subaction_entries.clear()
	var subaction_datas = data['SubActions']
	for index in range(24):
		if subaction_datas.get(str(index), '') is Dictionary:
			create_new_entry(index, subaction_datas[str(index)])
		if subaction_datas.get(str(index), '') is Array:
			for subsub in subaction_datas[str(index)]:
				create_new_entry(index, subsub)
			
