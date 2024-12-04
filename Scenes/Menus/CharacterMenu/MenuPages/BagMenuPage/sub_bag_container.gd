class_name SubBagContainer
extends VBoxContainer

@export var title_label:Label
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_sub_bag_data(tag, slots):
	title_label.text = tag
	for i in range(slots.size()):
		var new_button = load("res://Scenes/Menus/CharacterMenu/MenuPages/BagMenuPage/bag_item_slot_button.tscn").instantiate()
		new_button.get_child(1).pressed.connect(on_slot_pressed.bind(i))
		new_button.set_key(slots[i])
		self.add_child(new_button)
		new_button.visible = true

func on_slot_pressed(index:int):
	print("ButtonPresed!")
