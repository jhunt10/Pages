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
		if faction == "BaseFaction":
			continue
			
		# Check if encountered any in faction
		var encounterd_any = false
		for actor_key in ActorLibrary.list_actor_keys_in_faction(faction):
			if StoryState._encountered_actors.keys().has(actor_key):
				encounterd_any = true
				break
		if not encounterd_any:
			continue
		
		var button:CampOptionButton = premade_faction_label.duplicate()
		button.text = faction
		button.button.pressed.connect(on_faction_button_pressed.bind(faction))
		#button.get_child(0).pressed.connect(on_faction_button_pressed.bind(faction))
		faction_list_container.add_child(button)
		button.show()
	actors_tab_bar.tab_selected.connect(on_actor_tab_selected)
	exit_button.pressed.connect(on_close)
	on_faction_button_pressed("Players")

func on_faction_button_pressed(faction_key):
	#for child in actor_list_container.get_children():
		#child.queue_free()
	actors_tab_bar.clear_tabs()
	_tabbed_actor_keys.clear()
	#adding_tabs = true
	var min_index = -1
	adding_tabs = true
	for actor_key:String in ActorLibrary.list_actor_keys_in_faction(faction_key):
		# Skip base Actors
		if actor_key.begins_with("#"):
			continue
		# Skip hidden Actors
		var def = ActorLibrary.get_actor_def(actor_key)
		if not def.get("ActorData", {"ShowInArchive":false}).get("ShowInArchive", true):
			continue
		# Hide unencountered actors
		if not StoryState._encountered_actors.has(actor_key):
			_tabbed_actor_keys.append(null)
			actors_tab_bar.add_tab("     ?????     ")
			continue
		var display_name = def.get("#ObjDetails", {}).get("DisplayName", {})
		_tabbed_actor_keys.append(actor_key)
		actors_tab_bar.add_tab(display_name)
		if min_index < 0:
			min_index = _tabbed_actor_keys.size() -1
	adding_tabs = false
	if min_index >= 0:
		actors_tab_bar.current_tab = min_index
		

func on_actor_button_pressed(actor_key):
	if actor_key == "?????":
		return
	var actor = _cached_actors.get(actor_key)
	if not actor:
		actor = ActorLibrary.create_actor(actor_key, {})
		_cached_actors[actor_key] = actor
	actor_details_card.set_actor(actor)

func on_actor_tab_selected(index):
	if adding_tabs:
		return
	var actor_key = _tabbed_actor_keys[index]
	if !actor_key:
		return
	var actor = _cached_actors.get(actor_key)
	if not actor:
		actor = ActorLibrary.create_actor(actor_key, {})
		_cached_actors[actor_key] = actor
	actor_details_card.set_actor(actor)

func on_close():
	for actor:BaseActor in _cached_actors.values():
		ActorLibrary.delete_actor(actor)
	self.queue_free()
