class_name ActorPlacerControl
extends Control

signal actor_selected
signal confirm_pressed
@export var placed_actor_label:Label
@export var min_max_actor_label:Label
@export var confirm_button_label:Label
@export var confirm_button:Button

@export var actor_buttons_container:Container
@export var player1_button_control:ActorPlacerButton
@export var player2_button_control:ActorPlacerButton
@export var player3_button_control:ActorPlacerButton
@export var player4_button_control:ActorPlacerButton


var _actor_id_to_buttons:Dictionary = {}
var _actor_id_to_actor_node:Dictionary = {}
var _spawn_tile_map:TileMapLayer

var _placing_actor_id:String = ''
var min_actor_count:int = 1
var max_actor_count:int = 4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	confirm_button.button_down.connect(_on_confirm_button_down)
	confirm_button.button_up.connect(_on_confirm_button_up)
	#player1_button_control.pressed.connect(_on_actor_button_pressed.bind(player1_button_control))
	#player2_button_control.pressed.connect(_on_actor_button_pressed.bind(player2_button_control))
	#player3_button_control.pressed.connect(_on_actor_button_pressed.bind(player3_button_control))
	#player4_button_control.pressed.connect(_on_actor_button_pressed.bind(player4_button_control))
	pass # Replace with function body.

func _on_confirm_button_down():
	confirm_button.modulate = Color.GRAY
func _on_confirm_button_up():
	confirm_button.modulate = Color.WHITE
	confirm_pressed.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func load_and_show(min_actors:int=1, max_actors:int=4):
	var actors = StoryState.list_player_actor()
	var buttons = actor_buttons_container.get_children()
	_spawn_tile_map = CombatRootControl.Instance.MapController.player_spawn_area_tile_map
	var first_actor_id = ''
	var index = 0
	for button in buttons:
		if not button is ActorPlacerButton:
			continue
		if actors.size() <= index:
			button.hide()
		else:
			var actor = actors[index]
			if !actor:
				index += 1
				continue
			if first_actor_id == '':
				first_actor_id = actor.Id
			button.actor_icon.texture = actor.sprite.get_portrait_sprite()
			button.highlight.hide()
			button.pressed.connect(_on_actor_button_pressed.bind(actor.Id))
			button.actor_id = actor.Id
			var actor_node = CombatRootControl.get_actor_node(actor.Id)
			if not actor_node:
				printerr("ActorPlacerControl.load_and_show: No Actor Node found for Actor: '%s'." % [actor.Id])
				continue
			if actor_node.get_parent() != _spawn_tile_map:
				actor_node.reparent(_spawn_tile_map)
			else:
				_spawn_tile_map.add_child(actor_node)
			actor_node.hide()
			_actor_id_to_buttons[actor.Id] = button
			_actor_id_to_actor_node[actor.Id] = actor_node
		index += 1
	if index < buttons.size():
		for left_over in range(index, 4):
			var button:ActorPlacerButton = buttons[index]
			button.hide()
	max_actor_count = max_actors
	min_actor_count = min_actors
	if min_actors == max_actors:
		min_max_actor_label.text = str(min_actor_count)
	else:
		min_max_actor_label.text = str(min_actor_count) + "-" + str(max_actor_count)
	set_placed_actor_count(0)
	_on_actor_button_pressed(first_actor_id)

func set_placed_actor_count(count:int):
	placed_actor_label.text = str(count)
	if count >= min_actor_count:
		confirm_button_label.text = "Start"
		confirm_button.disabled = false
	else:
		confirm_button_label.text = "Waiting"
		confirm_button.disabled = true

func finish_placing():
	for key in _actor_id_to_buttons.keys():
		_actor_id_to_buttons[key].highlight.visible = false
	_placing_actor_id = ''

func darken_actor(actor_id):
	var button:ActorPlacerButton = _actor_id_to_buttons.get(actor_id)
	button.actor_icon.self_modulate = Color(0 ,0, 0, 0.5)

func _on_actor_button_pressed(actor_id):
	if _placing_actor_id != '':
		unplace_actor(_placing_actor_id)
	_placing_actor_id = actor_id
	for key in _actor_id_to_buttons.keys():
		if key == _placing_actor_id:
			_actor_id_to_buttons[key].actor_icon.self_modulate = Color.WHITE
			_actor_id_to_buttons[key].highlight.visible = true
		else:
			_actor_id_to_buttons[key].highlight.visible = false
	actor_selected.emit(actor_id)

func put_actor_in_spot(actor_id, spot, is_valid:bool = true):
	var actor_node:BaseActorNode = _actor_id_to_actor_node.get(actor_id)
	actor_node.reparent(_spawn_tile_map)
	if actor_node:
		actor_node.position = _spawn_tile_map.map_to_local(spot)
		actor_node.show()
	if is_valid:
		actor_node.modulate = Color.WHITE
	else:
		actor_node.modulate = Color.RED

func set_actor_rotation(placing_actor_id, direction):
	var actor_node:BaseActorNode = _actor_id_to_actor_node.get(placing_actor_id)
	if actor_node:
		actor_node.set_facing_dir(direction)

func unplace_actor(actor_id):
	var actor_node:BaseActorNode = _actor_id_to_actor_node.get(actor_id)
	actor_node.hide()
	_actor_id_to_buttons[actor_id].actor_icon.self_modulate = Color.WHITE
