class_name TutorialCardsController
extends Control

@export var title_label:Label
@export var back_button:Button
@export var back_button_background:NinePatchRect
@export var next_button:Button
@export var next_button_background:NinePatchRect

@export var page_que_card:Control
@export var movement_card:Control
@export var targeting_actor_card:Control
@export var targeting_spot_card:Control

var cards :Array

@export var card_index:int:
	set(val):
		var clamped_val = max(0, min(cards.size()-1, val))
		if clamped_val != card_index:
			card_index = clamped_val
			print("ChildCount: %s" % [card_index])
			for index in cards.size():
				cards[index].visible = index == card_index
				if index == card_index:
					title_label.text = cards[index].name.replace("_", " ")
			if card_index == 0:
				back_button_background.hide()
			else:
				back_button_background.show()
			if card_index == cards.size() -1:
				next_button_background.hide()
			else:
				next_button_background.show()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	card_index = card_index
	back_button.pressed.connect(_on_back)
	next_button.pressed.connect(_on_next)
	cards = [
		page_que_card,
		movement_card,
		targeting_actor_card,
		targeting_spot_card,
	]
	pass # Replace with function body.

func _on_next():
	card_index += 1
func _on_back():
	card_index -= 1
