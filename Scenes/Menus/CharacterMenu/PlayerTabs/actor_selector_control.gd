class_name ActorSelector
extends Control

@export var buttons_container:Container
var buttons = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sync_labels()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func sync_labels():
	for button in buttons_container.get_children():
		button.queue_free()
	buttons.clear()
	var button_scene = load("res://Scenes/Menus/CharacterMenu/PlayerTabs/player_tab_button.tscn")
	for actor in StoryState.list_party_actors():
		var new_button:PlayerTabButton = button_scene.instantiate()
		#if not actor.pages.items_changed.is_connected(sync_labels):
			#actor.pages.items_changed.connect(sync_labels)
		var title_page:BasePageItem = actor.pages.get_item_in_slot(0)
		if title_page:
			new_button.button_label.text = title_page.get_display_name()
		buttons[actor.Id] = (new_button)
		new_button.button.pressed.connect(actor_pressed.bind(actor.Id))
		new_button.show()
		buttons_container.add_child(new_button)
		new_button.button_texture.self_modulate = StoryState.get_player_color(actor)

func set_selected_actor(actor):
	var i = 0
	for but_act_id in buttons.keys():
		var button:PlayerTabButton = buttons[but_act_id]
		button.showing = (actor and but_act_id == actor.Id)

func actor_pressed(actor_id):
	for but_act_id in buttons.keys():
		var button:PlayerTabButton = buttons[but_act_id]
		button.showing = (but_act_id == actor_id)
	var actor = ActorLibrary.get_actor(actor_id)
	if actor:
		CharacterMenuControl.Instance.on_actor_tab_selected(actor)
	pass
