class_name MainRootNode
extends Control

var current_scene

static var action_library = ActionLibrary.new()
static var item_libary = ItemLibrary.new()
static var actor_libary = ActorLibrary.new()
static var effect_libary = EffectLibrary.new()
static var vfx_libray = VfxLibrary.new()
static var Instance:MainRootNode

@export var center_container:CenterContainer

func _ready() -> void:
	if MainRootNode.Instance:
		printerr("MainRootNode already exists.")
		self.queue_free()
		return
	Instance = self
	#ActorLibrary.load_from_files()
	current_scene = load("res://Scenes/Menus/MainMenu/main_menu_root_control.tscn").instantiate()
	center_container.add_child(current_scene)

func _load_test_map():
	var file = FileAccess.open("res://data/Maps/_ExampleMap.json", FileAccess.READ)
	var text:String = file.get_as_text()
	return JSON.parse_string(text)

func start_combat():
	current_scene.queue_free()
	var combat_scene:CombatRootControl = load("res://Scenes/Combat/combat_scene.tscn").instantiate()
	var actors = []
	var actor = ActorLibrary.get_actor("TestActor_ID")
	#actor.equipment.equipt_weapon( ItemLibrary.create_item("TestSword", {}))
	actors.append({
		'ActorId': 'TestActor_ID',
		'Pos': MapPos.new(5,5,0,2),
		'IsPlayer': true,
		'IsEnemy':false
	})
	actors.append({
		'ActorId': 'TestTarget_ID',
		'Pos': MapPos.new(5,2,0,2),
		'IsPlayer': false,
		'IsEnemy':true
	})
	actors.append({
		'ActorId': 'TestTarget_ID2',
		'Pos': MapPos.new(5,6,0,2),
		'IsPlayer': false,
		'IsEnemy':true
	})
	actors.append({
		'ActorId': 'TestTarget_ID3',
		'Pos': MapPos.new(4,1,0,2),
		'IsPlayer': false,
		'IsEnemy':true
	})
	actors.append({
		'ActorId': 'TestTarget_ID4',
		'Pos': MapPos.new(3,5,0,2),
		'IsPlayer': false,
		'IsEnemy':true
	})
	actors.append({
		'ActorId': 'TestTarget_ID5',
		'Pos': MapPos.new(8,5,0,2),
		'IsPlayer': false,
		'IsEnemy':true
	})
	#actors.append({
		#'ActorKey': 'TestTarget',
		#'Pos': MapPos.new(6,2,0,0),
	#})
	var map_data = _load_test_map()
	combat_scene.set_init_state(map_data, actors)
	current_scene = combat_scene
	center_container.add_child(current_scene)

func open_character_sheet(_actor:BaseActor=null)->EquipmentMenuContainer:
	var actor = _actor
	if not actor:
		actor = ActorLibrary.get_actor("TestActor_ID")
		#actor = ActorLibrary.create_actor("TestActor", {})
	var charsheet:EquipmentMenuContainer = load("res://Scenes/Menus/EquipmentMenu/equipment_menu.tscn").instantiate()
	center_container.add_child(charsheet)
	charsheet.set_actor(actor)
	return charsheet

func open_page_menu(actor:BaseActor):
	var page_menu = load("res://Scenes/Menus/PageQueMenu/page_que_menu.tscn").instantiate()
	center_container.add_child(page_menu)
	page_menu.set_actor(actor)
	return page_menu
	
func open_page_editor():
	var page_editor = load("res://Scenes/Editors/PageEditor/page_editor_control_scene.tscn").instantiate()
	self.add_child(page_editor)
	
	
func open_effect_editor():
	var page_editor = load("res://Scenes/Editors/EffectEditor/effect_editor_control_scene.tscn").instantiate()
	center_container.add_child(page_editor)

func open_tutorial():
	var tutorial = load("res://Scenes/Menus/tutorial_menu_control.tscn").instantiate()
	center_container.add_child(tutorial)
	
func go_to_main_menu():
	current_scene.queue_free()
	current_scene = load("res://Scenes/Menus/MainMenu/main_menu_root_control.tscn").instantiate()
	center_container.add_child(current_scene)
	
