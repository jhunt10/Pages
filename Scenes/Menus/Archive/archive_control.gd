class_name ArchiveControl
extends Control

@export var exit_button:Button
@export var actor_details_card:ActorDetailsCard
@export var faction_list_container:BoxContainer
@export var actors_tab_bar:TabBar

@export var premade_faction_label:CampOptionButton

var _cached_actors:Dictionary = {}
var _tabbed_actor_keys:Array = []

var adding_tabs:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	premade_faction_label.hide()
	for faction in ActorLibrary.list_factions():
		var button:CampOptionButton = premade_faction_label.duplicate()
		button.text = faction
		button.button.pressed.connect(on_faction_button_pressed.bind(faction))
		#button.get_child(0).pressed.connect(on_faction_button_pressed.bind(faction))
		faction_list_container.add_child(button)
		button.show()
	actors_tab_bar.tab_selected.connect(on_actor_tab_selected)
	exit_button.pressed.connect(on_close)

func on_faction_button_pressed(faction_key):
	#for child in actor_list_container.get_children():
		#child.queue_free()
	actors_tab_bar.clear_tabs()
	_tabbed_actor_keys.clear()
	#adding_tabs = true
	for actor_key:String in ActorLibrary.list_actor_keys_in_faction(faction_key):
		if actor_key.begins_with("#"):
			continue
		var def = ActorLibrary.get_actor_def(actor_key)
		var display_name = def.get("#ObjDetails", {}).get("DisplayName", {})
		#var button = Button.new()
		#button.text = 
		#button.pressed.connect(on_actor_button_pressed.bind(actor_key))
		#actor_list_container.add_child(button)
		_tabbed_actor_keys.append(actor_key)
		actors_tab_bar.add_tab(display_name)
	adding_tabs = false
		

func on_actor_button_pressed(actor_key):
	var actor = _cached_actors.get(actor_key)
	if not actor:
		actor = ActorLibrary.create_actor(actor_key, {})
		_cached_actors[actor_key] = actor
	actor_details_card.set_actor(actor)

func on_actor_tab_selected(index):
	if adding_tabs:
		return
	var actor_key = _tabbed_actor_keys[index]
	var actor = _cached_actors.get(actor_key)
	if not actor:
		actor = ActorLibrary.create_actor(actor_key, {})
		_cached_actors[actor_key] = actor
	actor_details_card.set_actor(actor)

func on_close():
	for actor:BaseActor in _cached_actors.values():
		ActorLibrary.delete_actor(actor)
	self.queue_free()
