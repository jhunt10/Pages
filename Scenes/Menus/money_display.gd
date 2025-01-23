extends HBoxContainer

@export var label:Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	StoryState.Instance.money_changed.connect(set_money)
	set_money()

func set_money():
	label.text = str(StoryState.get_current_money())
