extends Control

@export var action_count_label:Label
@export var actor_count_label:Label
@export var item_count_label:Label
@export var effect_count_label:Label

@export var list_container:VBoxContainer
@export var recount_button:Button
@export var list_button:OptionButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	recount_button.pressed.connect(_recount)
	list_button.item_selected.connect(_on_lsit_selected)
	_recount()


func _recount():
	if ActionLibrary.Instance:
		action_count_label.text = str(ActionLibrary.Instance._loaded_objects.size())
	else:
		action_count_label.text = "NA"
		
	if ActorLibrary.Instance:
		actor_count_label.text = str(ActorLibrary.Instance._loaded_objects.size())
	else:
		actor_count_label.text = "NA"
		
	if ItemLibrary.Instance:
		item_count_label.text = str(ItemLibrary.Instance._loaded_objects.size())
	else:
		item_count_label.text = "NA"
		
	if EffectLibrary.Instance:
		effect_count_label.text = str(EffectLibrary.Instance._loaded_objects.size())
	else:
		effect_count_label.text = "NA"

func _on_lsit_selected(index:int):
	for child in list_container.get_children():
		child.queue_free()
	if index == 0:
		for actor_id in ActorLibrary.Instance._loaded_objects.keys():
			var actor = ActorLibrary.get_actor(actor_id)
			var line = actor_id + ":" + str(actor.FactionIndex)
			add_label(line)
	if index == 1:
		for item_id in ItemLibrary.Instance._loaded_objects.keys():
			add_label(item_id)
	if index == 2:
		for item_id in EffectLibrary.Instance._loaded_objects.keys():
			add_label(item_id)

func add_label(text):
	var new_label = Label.new()
	new_label.text = text
	list_container.add_child(new_label)
