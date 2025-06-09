class_name ActorSelector
extends Control

@export var actor_1_button:PlayerTabButton
@export var actor_2_button:PlayerTabButton
@export var actor_3_button:PlayerTabButton
@export var actor_4_button:PlayerTabButton

var buttons = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	actor_1_button.button.pressed.connect(actor_pressed.bind(0))
	actor_2_button.button.pressed.connect(actor_pressed.bind(1))
	actor_3_button.button.pressed.connect(actor_pressed.bind(2))
	actor_4_button.button.pressed.connect(actor_pressed.bind(3))
	buttons = [actor_1_button, actor_2_button, actor_3_button, actor_4_button]
	sync_labels()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func sync_labels():
	for index in range(4):
		var actor = StoryState.get_player_actor(index)
		if not actor:
			buttons[index].hide()
			continue
		if not actor.pages.class_page_changed.is_connected(sync_labels):
			actor.pages.class_page_changed.connect(sync_labels)
		var title_page:BasePageItem = actor.pages.get_item_in_slot(0)
		if title_page:
			buttons[index].button_label.text = title_page.get_display_name()
			buttons[index].button_texture.self_modulate = StoryState.get_player_color(index)

func set_selected_actor(actor):
	var player_index = StoryState.get_player_index_of_actor(actor)
	var i = 0
	for button:PlayerTabButton in buttons:
		button.showing = i == player_index
		i += 1

func actor_pressed(index:int):
	var i = 0
	for button:PlayerTabButton in buttons:
		button.showing = i == index
		i += 1
	var actor = StoryState.get_player_actor(index)
	if actor:
		CharacterMenuControl.Instance.set_actor(actor)
	pass
