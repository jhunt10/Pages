class_name InventorySubGroupContainer
extends VBoxContainer

@export var label:Label
@export var inner_container:Container

var buttons:Dictionary = {}
var group_key:String = ''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_inner_container()->Container:
	return $FlowContainer

func set_group_key(key:String):
	group_key = key
	var tokens = key.split(":")
	var name_str = ''
	if tokens.has("TitleLocked"):
		var lock_index = tokens.find("TitleLocked")
		name_str += tokens[lock_index+1] + " "
	elif tokens.has("Shared"):
		name_str += "Shared "
	name_str += tokens[-1]
	label.text = name_str + "s"
	

func add_item_button(button:InventoryItemButton):
	get_inner_container().add_child(button)
	buttons[button._item_id] = button
