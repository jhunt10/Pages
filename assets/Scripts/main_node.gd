class_name MainRootNode
extends Control

var current_scene

static var action_libary = ActionLibary.new()
static var actor_libary = ActorLibary.new()
static var effect_libary = EffectLibary.new()
static var item_libary = ItemLibary.new()
static var Instance:MainRootNode

func _ready() -> void:
	if MainRootNode.Instance:
		printerr("MainRootNode already exists.")
		self.queue_free()
		return
	Instance = self
	current_scene = load("res://Scenes/main_menu_root_control.tscn").instantiate()
	self.add_child(current_scene)

func _load_test_map():
	var file = FileAccess.open("res://data/Maps/_ExampleMap.json", FileAccess.READ)
	var text:String = file.get_as_text()
	return JSON.parse_string(text)

func start_combat():
	current_scene.queue_free()
	var combat_scene:CombatRootControl = load("res://Scenes/combat_scene.tscn").instantiate()
	var actors = {}
	actors['TestTarget'] = MapPos.new(5,2,0,0)
	actors['TestOtherTarget'] = MapPos.new(5,2,1,0)
	actors['TestActor'] = MapPos.new(5,5,0,0)
	var map_data = _load_test_map()
	combat_scene.set_init_state(map_data, "TestActor", actors)
	current_scene = combat_scene
	self.add_child(current_scene)

func open_character_sheet(_actor:BaseActor=null):
	var actor = _actor
	if not actor:
		var actor_data = MainRootNode.actor_libary.get_actor_data("TestActor")
		actor = BaseActor.new(actor_data, 0)
	var charsheet = load("res://Scenes/character_edit_control.tscn").instantiate()
	self.add_child(charsheet)
	charsheet.set_actor(actor)
	pass
	
func open_page_editor():
	var page_editor = load("res://Scenes/UiNodes/page_editor_control.tscn").instantiate()
	self.add_child(page_editor)
	
	
func open_effect_editor():
	var page_editor = load("res://Scenes/UiNodes/effect_editor_control.tscn").instantiate()
	self.add_child(page_editor)
	
	
func go_to_main_menu():
	current_scene.queue_free()
	current_scene = load("res://Scenes/main_menu_root_control.tscn").instantiate()
	self.add_child(current_scene)
	
