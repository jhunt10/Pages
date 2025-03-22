class_name ActorPlacerControl
extends Control

@export var player1_button_control:ActorPlacerButton
@export var player2_button_control:ActorPlacerButton
@export var player3_button_control:ActorPlacerButton
@export var player4_button_control:ActorPlacerButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player1_button_control.pressed.connect(_on_button_pressed.bind(player1_button_control))
	player2_button_control.pressed.connect(_on_button_pressed.bind(player2_button_control))
	player3_button_control.pressed.connect(_on_button_pressed.bind(player3_button_control))
	player4_button_control.pressed.connect(_on_button_pressed.bind(player4_button_control))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_and_show():
	var actors = StoryState.list_player_actor()
	var buttons = [player1_button_control, player2_button_control, player3_button_control, player4_button_control, ]
	var index = 0
	for actor:BaseActor in actors:
		var button:ActorPlacerButton = buttons[index]
		button.actor_icon.texture = actor.sprite.get_portrait_sprite()
		button.actor_id = actor.Id

func _on_button_pressed(button:ActorPlacerButton):
	pass
