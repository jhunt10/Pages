class_name TutorialCardsController
extends Control

signal closed

@export var top_container:Control
@export var title_label:Label
@export var count_label:Label
@export var close_button:Button
@export var back_button:Button
@export var back_button_background:NinePatchRect
@export var next_button:Button
@export var next_button_background:NinePatchRect
@export var done_button:Button
@export var done_button_background:NinePatchRect

@export var page_que_card:Control
@export var movement_card:Control
@export var targeting_actor_card:Control
@export var targeting_spot_card:Control
@export var ppr_card:Control
@export var speed_card:Control
@export var mass_card:Control
@export var armor_card:Control
@export var block_evade_card:Control
@export var item_card:Control
@export var item2_card:Control
@export var ammo_card:Control
@export var weapon_card:Control

var cards:Dictionary

var card_list:Array = []

@export var card_index:int:
	set(val):
		var clamped_val = max(0, min(card_list.size()-1, val))
		if card_list.size() > 0:
			if val >= 0:
				card_index = clamped_val
			for card in cards.values():
				card.visible = false
			var cur_card_key = card_list[card_index]
			title_label.text = cur_card_key
			cards[cur_card_key].visible = true
			count_label.text = " " + str(card_index+1) + "/" + str(card_list.size()) + "  "
			if card_index == 0:
				back_button_background.hide()
			else:
				back_button_background.show()
			if card_index == card_list.size() -1:
				next_button_background.hide()
				done_button_background.show()
			else:
				next_button_background.show()
				done_button_background.hide()
				


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if top_container and not top_container.visible:
		var parent = top_container.get_parent()
		parent.remove_child(top_container)
		parent.add_child(top_container)
		top_container.show()
	back_button.pressed.connect(_on_back)
	next_button.pressed.connect(_on_next)
	done_button.pressed.connect(_on_done)
	close_button.pressed.connect(_on_done)
	cards = {
		"Page Que": page_que_card,
		"Movement": movement_card,
		"Targeting Actors": targeting_actor_card,
		"Targeting Spots": targeting_spot_card,
		"Turns and Gaps": ppr_card,
		"Turn Order": speed_card,
		"Crashing": mass_card,
		"Armor and Damage": armor_card,
		"Block and Evade": block_evade_card,
		"Items": item_card,
		"Items 2": item2_card,
		"Page Ammo": ammo_card,
		"Weapons": weapon_card
	}
	card_list = [
		"Page Que",
		"Movement",
		"Targeting Actors",
		"Targeting Spots",
		"Turns and Gaps",
		"Turn Order",
		"Crashing",
		"Armor and Damage",
		"Block and Evade",
		"Items",
		"Items 2",
		"Page Ammo",
		"Weapons"
	]
	card_index = card_index

func _on_next():
	card_index += 1
func _on_back():
	card_index -= 1
func _on_done():
	closed.emit()
	self.queue_free()
