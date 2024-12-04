class_name MainRootNode
extends Control

var current_scene

static var action_library:ActionLibrary:
	get: 
		if !action_library:
			action_library = ActionLibrary.new()
		return action_library

static var item_libary:ItemLibrary:
	get: 
		if !item_libary:
			item_libary = ItemLibrary.new()
		return item_libary

static var actor_libary:ActorLibrary:
	get: 
		if !actor_libary:
			actor_libary = ActorLibrary.new()
		return actor_libary

static var effect_libary:EffectLibrary:
	get: 
		if !effect_libary:
			effect_libary = EffectLibrary.new()
		return effect_libary

static var vfx_libray:VfxLibrary:
	get: 
		if !vfx_libray:
			vfx_libray = VfxLibrary.new()
		return vfx_libray
		
static var Instance:MainRootNode

@export var center_container:CenterContainer

static var is_mobile:bool:
	get: return true# OS.has_feature("web_android") or OS.has_feature("web_ios")

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
	var file = FileAccess.open("res://data/Maps/FirstMap.json", FileAccess.READ)
	var text:String = file.get_as_text()
	return JSON.parse_string(text)

func start_combat():
	current_scene.queue_free()
	var combat_scene:CombatRootControl = load("res://Scenes/Combat/combat_scene.tscn").instantiate()
	combat_scene.load_init_state("res://Scenes/Maps/working_map.tscn")
	current_scene = combat_scene
	self.add_child(current_scene)

func open_character_sheet(_actor:BaseActor=null, parent_node=null)->CharacterMenuControl:
	var actor = _actor
	if not actor:
		actor = ActorLibrary.get_or_create_actor("TestActor", "TestActor_ID")
		#actor = ActorLibrary.create_actor("TestActor", {})
	var charsheet:CharacterMenuControl = load("res://Scenes/Menus/CharacterMenu/character_menu.tscn").instantiate()
	var screen_size = self.size
	#if screen_size.y > charsheet.size.y * 1.5:
		#charsheet.scale_control.scale = Vector2(1.5, 1.5)
	if parent_node:
		parent_node.add_child(charsheet)
	else:
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
	if current_scene:
		current_scene.queue_free()
	var combat_scene:CombatRootControl = load("res://Scenes/Combat/combat_scene.tscn").instantiate()
	combat_scene.load_init_state("res://Scenes/Maps/Tutorial/tutorial_map.tscn")
	current_scene = combat_scene
	self.add_child(current_scene)
	
	var dialog:DialogControl = load("res://Scenes/Dialog/dialog_control.tscn").instantiate()
	dialog.scene_root = combat_scene
	dialog.load_dialog_script("res://data/DialogScripts/TutorialDialog.json")
	combat_scene.camera.canvas_layer.add_child(dialog)
	
func go_to_main_menu():
	current_scene.queue_free()
	current_scene = load("res://Scenes/Menus/MainMenu/main_menu_root_control.tscn").instantiate()
	center_container.add_child(current_scene)
	
