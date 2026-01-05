class_name AggroMenu
extends Control

@export var close_button:Button
@export var actors_options_button:LoadedOptionButton
@export var list_container:VBoxContainer
@export var premade_label:Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close_button.pressed.connect(self.hide)
	actors_options_button.get_options_func = get_actors
	actors_options_button.item_selected.connect(on_actor_selected)

func get_actors()->Array:
	if not CombatRootControl.Instance:
		return []
	return CombatRootControl.Instance.GameState._actors.keys()

func on_actor_selected(index:int):
	if not CombatRootControl.Instance:
		return
	for child in list_container.get_children():
		child.queue_free()
	var actor_id = actors_options_button.get_item_text(index)
	var actor = ActorLibrary.get_actor(actor_id)
	if not actor:
		var new_label = premade_label.duplicate()
		new_label.text = "Actor Not Found"
		list_container.add_child(new_label)
		new_label.show()
		return
	var threats = actor.aggro.actor_id_to_threat
	
	if threats.size() == 0:
		var new_label = premade_label.duplicate()
		new_label.text = "No Threats"
		list_container.add_child(new_label)
		new_label.show()
		return
	
	for threat_id in threats.keys():
		var new_label = premade_label.duplicate()
		new_label.text = threat_id + "   |   " + str(threats[threat_id])
		list_container.add_child(new_label)
		new_label.show()
		
