class_name ActorSelector
extends Control

@export var actor_1_button:Button
@export var actor_2_button:Button
@export var actor_3_button:Button
@export var actor_4_button:Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	actor_1_button.pressed.connect(actor_pressed.bind(0))
	actor_2_button.pressed.connect(actor_pressed.bind(1))
	actor_3_button.pressed.connect(actor_pressed.bind(2))
	actor_4_button.pressed.connect(actor_pressed.bind(3))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func actor_pressed(index:int):
	var actor = StoryState.get_player_actor(index)
	if actor:
		CharacterMenuControl.Instance.set_actor(actor)
	pass
