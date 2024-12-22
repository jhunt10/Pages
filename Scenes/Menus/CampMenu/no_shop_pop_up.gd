class_name NoShopPopUp
extends Control

@export var close_button:Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close_button.pressed.connect(hide)
	pass # Replace with function body.

func do_thing():
	self.show()
	for item_key in ItemLibrary.list_all_item_keys():
		var new_item_id = item_key+"1"
		if not PlayerInventory.has_item_id(new_item_id):
			var new_item = ItemLibrary.get_or_create_item(new_item_id, item_key, {})
			if !new_item:
				printerr("DevTools.items_to_inventory: Failed to create item '%s'." % [new_item_id])
			else:
				PlayerInventory.add_item(new_item)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
