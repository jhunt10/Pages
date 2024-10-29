class_name MainRootNode
extends Control

var current_scene

static var action_library = ActionLibrary.new()
static var actor_libary = ActorLibrary.new()
static var effect_libary = EffectLibary.new()
static var item_libary = ItemLibrary.new()
static var vfx_libray = VfxLibrary.new()
static var Instance:MainRootNode

func _ready() -> void:
	if MainRootNode.Instance:
		printerr("MainRootNode already exists.")
		self.queue_free()
		return
	Instance = self
	#ActorLibrary.load_from_files()
	current_scene = load("res://Scenes/main_menu_root_control.tscn").instantiate()
	self.add_child(current_scene)

func _load_test_map():
	var file = FileAccess.open("res://data/Maps/_ExampleMap.json", FileAccess.READ)
	var text:String = file.get_as_text()
	return JSON.parse_string(text)

func start_combat():
	current_scene.queue_free()
	var combat_scene:CombatRootControl = load("res://Scenes/combat_scene.tscn").instantiate()
	var actors = []
	actors.append({
		'ActorKey': 'TestActor',
		'Pos': MapPos.new(5,5,0,0),
		'IsPlayer': true
	})
	actors.append({
		'ActorKey': 'TestTarget',
		'Pos': MapPos.new(5,2,0,0),
	})
	actors.append({
		'ActorKey': 'TestTarget',
		'Pos': MapPos.new(6,2,0,0),
	})
	var map_data = _load_test_map()
	combat_scene.set_init_state(map_data, actors)
	current_scene = combat_scene
	self.add_child(current_scene)

func open_character_sheet(_actor:BaseActor=null):
	var actor = _actor
	if not actor:
		actor = ActorLibrary.get_actor("TestActor_ID")
		
		actor.equipment.equipt_que(
			ItemLibrary.create_item("TestPageQue", {}))
			
		actor.equipment.equipt_bag(
			ItemLibrary.create_item("TestBag", {}))
			
		actor.equipment.equipt_armor(
			ItemLibrary.create_item("TestHelm", {}))
			
		actor.equipment.equipt_armor(
			ItemLibrary.create_item("TestShirt", {}))
			
		actor.equipment.equipt_armor(
			ItemLibrary.create_item("TestBoots", {}))
			
		actor.equipment.equipt_armor(
			ItemLibrary.create_item("TestTrinket", {}))
			
		#actor = ActorLibrary.create_actor("TestActor", {})
	var charsheet = load("res://Scenes/character_edit_control.tscn").instantiate()
	self.add_child(charsheet)
	charsheet.set_actor(actor)
	pass
	
func open_page_editor():
	var page_editor = load("res://Scenes/Editors/PageEditor/page_editor_control_scene.tscn").instantiate()
	self.add_child(page_editor)
	
	
func open_effect_editor():
	var page_editor = load("res://Scenes/Editors/EffectEditor/effect_editor_control_scene.tscn").instantiate()
	self.add_child(page_editor)
	
	
func go_to_main_menu():
	current_scene.queue_free()
	current_scene = load("res://Scenes/main_menu_root_control.tscn").instantiate()
	self.add_child(current_scene)
	
