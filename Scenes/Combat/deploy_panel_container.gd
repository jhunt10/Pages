class_name DeployPanelContainer
extends PanelContainer

@export var buttons_container:BoxContainer
@export var premade_button:Button

var timer = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	premade_button.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer -= delta
	if timer < 0:
		timer = 1
		_sync_deployable_actors()

func _sync_deployable_actors():
	for child in buttons_container.get_children():
		if child != premade_button:
			child.queue_free()
	var main_actor:CarrierActor = StoryState.list_party_actors()[0]
	for sub_actor:BaseActor in main_actor.list_held_actors():
		var new_button = premade_button.duplicate()
		new_button.text = sub_actor.get_display_name()
		new_button.show()
		new_button.pressed.connect(_on_deploy.bind(sub_actor.Id))
		buttons_container.add_child(new_button)
		
func _on_deploy(actor_id):
	var actor = CombatRootControl.Instance.GameState.get_actor(actor_id)
	var main_actor:CarrierActor = CombatRootControl.list_player_actors()[0]
	var pos = CombatRootControl.Instance.GameState.get_actor_pos(main_actor)
	pos = pos.apply_relative_pos(MapPos.new(0,-1,0,0))
	
	CombatRootControl.Instance.deploy_actor(actor, pos)
	_sync_deployable_actors()
	
	
