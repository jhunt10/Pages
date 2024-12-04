class_name BagPageControl
extends Control

@export var name_label:Label
@export var bag_icon:TextureRect
@export var premade_sub_container:SubBagContainer
@export var sub_container:VBoxContainer
@export var scroll_bar:CustScrollBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	premade_sub_container.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func set_actor(actor:BaseActor):
	var bags = actor.equipment.get_equipt_items_of_slot_type("Bag")
	if !bags or bags.size() == 0:
		name_label.text = "No Bag!"
		return
	elif bags.size() > 1:
		name_label.text = "2 Bags?"
		return
	var bag:BaseBagEquipment = bags[0]
	name_label.text = bag.details.display_name
	bag_icon.texture = bag.get_large_icon()
	
	var tags = actor.items.get_item_ids_per_item_tags()
	for tag in tags.keys():
		var slots = tags[tag]
		var sub = _create_sub_container(tag, slots)
	scroll_bar.calc_bar_size()
	scroll_bar.set_scroll_bar_percent(0)

func _create_sub_container(tag, slots)->SubBagContainer:
	var new_sub:SubBagContainer = premade_sub_container.duplicate()
	new_sub.set_sub_bag_data(tag, slots)
	sub_container.add_child(new_sub)
	new_sub.visible = true
	return new_sub
