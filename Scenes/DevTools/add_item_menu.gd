class_name AddItemMenu
extends Control

@export var close_button:Button
@export var item_options_button:LoadedOptionButton
@export var spinner:SpinBox
@export var confirm_button:Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close_button.pressed.connect(self.hide)
	item_options_button.get_options_func = get_item_keys
	confirm_button.pressed.connect(add_items)

func get_item_keys()->Array:
	return ItemLibrary.list_all_item_keys()

func add_items():
	var item_key = item_options_button.get_current_option_text()
	var count = spinner.value
	for i in range(count):
		var new_item = ItemLibrary.create_item(item_key, {})
		if not new_item:
			printerr("Failed to make new item: " + item_key)
			return
		PlayerInventory.add_item(new_item)
