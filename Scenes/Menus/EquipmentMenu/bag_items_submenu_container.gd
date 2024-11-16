@tool
class_name BagItemsSubMenuContainer
extends BackPatchContainer

@export var close_button:Button
@export var item_slots_container:VBoxContainer
@export var premade_item_slot_button:BagItemSlotButton

var _actor:BaseActor

func _ready() -> void:
	premade_item_slot_button.visible = false

func set_actor(actor:BaseActor):
	if _actor:
		if _actor.bag_items_changed.is_connected(_load_items):
			_actor.bag_items_changed.disconnect(_load_items)
	_actor = actor
	_actor.bag_items_changed.connect(_load_items)
	_load_items()

func _load_items():
	for child in item_slots_container.get_children():
		child.queue_free()
	var item_count = _actor.items.get_max_item_count()
	var items = _actor.items.get_items_per_item_tags()
	for item_tags in items.keys():
		_create_new_item_tags_entry(item_tags, items[item_tags])

func _create_new_item_tags_entry(item_tags:String, items:Array):
	#var new_slot_entry:PageTagSlotsEntry = premade_item_tag_slots_entry.duplicate()
	#new_slot_entry.visible = true
	#new_slot_entry.title.text = item_tags
	var label = Label.new()
	item_slots_container.add_child(label)
	label.text = item_tags
	for index in range(items.size()):
		var item:BaseItem = null
		if items[index]:
			item = ItemLibrary.get_item(items[index])
		var new_slot = _create_item_slots(item_tags, index,item)
		item_slots_container.add_child(new_slot)

func _create_item_slots(item_tags:String, index:int, item:BaseItem):
	var new_slot:BagItemSlotButton = premade_item_slot_button.duplicate()
	new_slot.visible = true
	var item_id = ''
	if item:
		item_id = item.Id
		new_slot.set_item(item)
	new_slot.pressed.connect(on_item_slot_pressed.bind(item_tags, index, item_id))
	return new_slot
	
func on_item_slot_pressed(tags:String, index:int, item_id:String):
	var item = ItemLibrary.get_item(item_id)
	if item:
		PlayerInventory.add_item(item)
	_actor.items.set_item_for_slot(tags, index, null)
