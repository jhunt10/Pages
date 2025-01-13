class_name DropMessageControl
extends Control

@export var premade_drop_card:DropMessageCard
@export var card_hight:int = 48
@export var drop_speed:float = 300

var cards:Array = []
var current_top:float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	premade_drop_card.hide()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_top < 0:
		var move = min(delta * 300, 0 - current_top)
		current_top += move
		for card in cards:
			card.position.y += move
	pass

func add_card(message:String, icon:Texture2D = null, icon_background:Texture2D = null):
	var new_card:DropMessageCard = premade_drop_card.duplicate()
	new_card.label.text = message
	if icon:
		new_card.icon_background.texture = icon_background
		new_card.icon_rect.texture = icon
	else:
		new_card.icon_background.hide()
	new_card.finished.connect(card_finished.bind(new_card))
	self.add_child(new_card)
	current_top -= card_hight
	new_card.position = Vector2i(0, current_top)
	new_card.show()
	cards.append(new_card)

func card_finished(card:DropMessageCard):
	cards.erase(card)
	card.queue_free()
