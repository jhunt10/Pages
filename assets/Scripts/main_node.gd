class_name MainRootNode
extends Control

var current_scene

static var action_library:ActionLibrary:
	get: 
		if !action_library:
			action_library = ActionLibrary.new()
		return action_library

static var vfx_libray:VfxLibrary:
	get: 
		if !vfx_libray:
			vfx_libray = VfxLibrary.new()
		return vfx_libray
		
static var Instance:MainRootNode

@export var center_container:CenterContainer

static var is_mobile:bool:
	get: return false# OS.has_feature("web_android") or OS.has_feature("web_ios")

func _ready() -> void:
	printerr("\n")
	printerr(OS.get_data_dir())
	printerr("\n")
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

func set_current_scene(scene):
	if current_scene and is_instance_valid(current_scene):
		current_scene.queue_free()
	current_scene = scene
	self.add_child(scene)

func start_combat(map_scene_path):
	#var map_data = MapLoader.get_map_data(map_key)
	#var map_path = map_data['LoadPath'].path_join(map_data.get("MapScene", ""))
	#current_scene.queue_free()
	LoadManager.load_combat(map_scene_path)
	#var combat_scene:CombatRootControl = load().instantiate()
	#if not combat_scene:
		#printerr("Failed to start combat on map '%s'. No MapScene found for: '%s'." % [map_key, map_path])
		#return
	#combat_scene.load_init_state(map_path)
	#current_scene = combat_scene
	#self.add_child(current_scene)

func start_game():
	if !ActionLibrary.Instance: var lib = ActionLibrary.new()
	if !ItemLibrary.Instance: var lib = ItemLibrary.new()
	if !EffectLibrary.Instance: var lib = EffectLibrary.new()
	if !ActorLibrary.Instance: var lib = ActorLibrary.new()
	StoryState.start_new_story()
	#var char_select:StartCharacterSelectMenu = load("res://Scenes/Menus/StartCharacterSelectMenu/start_character_select_menu.tscn").instantiate()
	#self.add_child(char_select)
	##char_select.character_selected.connect(_on_start_character_selected)
	#current_scene = char_select

#func _on_start_character_selected(name):
	#StoryState.start_new_story()
	#if current_scene:
		#current_scene.queue_free()
	#var combat_scene:CombatRootControl = load("res://Scenes/Combat/combat_scene.tscn").instantiate()
	#combat_scene.load_init_state("res://Scenes/Maps/StoryMaps/1_StartingMap/starting_map.tscn")
	#current_scene = combat_scene
	#self.add_child(current_scene)
	#
	#var dialog:DialogController = load("res://Scenes/Dialog/dialog_control.tscn").instantiate()
	#dialog.scene_root = combat_scene
	#dialog.load_dialog_script("res://Scenes/Maps/StoryMaps/1_StartingMap/start_game_dialog_script.json")
	#combat_scene.camera.canvas_layer.add_child(dialog)
	##open_camp_menu()

func open_save_menu():
	var save_scene:SaveLoadMenu = load("res://Scenes/Menus/SaveLoadMenu/save_load_menu.tscn").instantiate()
	save_scene.save_mode = true
	var screen_size = self.size
	var scale = screen_size.y / save_scene.size.y
	save_scene.scale_control.scale = Vector2(scale, scale)
	if screen_size.y > save_scene.size.y * 1.5:
		save_scene.scale_control.scale = Vector2(1.5, 1.5)
	self.add_child(save_scene)

func open_load_menu():
	var save_scene:SaveLoadMenu = load("res://Scenes/Menus/SaveLoadMenu/save_load_menu.tscn").instantiate()
	save_scene.save_mode = false
	var screen_size = self.size
	var scale = screen_size.y / save_scene.size.y
	save_scene.scale_control.scale = Vector2(1, 1)
	if screen_size.y > save_scene.size.y * 1.5:
		save_scene.scale_control.scale = Vector2(1.5, 1.5)
	self.add_child(save_scene)

func open_camp_menu(dialog_script:String=''):
	if current_scene is CampMenu and dialog_script == '':
		
		return
	#current_scene.queue_free()
	#prune_objects()
	var data = {}
	if dialog_script != '':
		data['DialogScript'] = dialog_script
	LoadManager.load_scene("res://Scenes/Menus/CampMenu/camp_menu.tscn", data)
	#var camp_scene = load("res://Scenes/Menus/CampMenu/camp_menu.tscn").instantiate()
	#self.add_child(camp_scene)
	#current_scene = camp_scene
	


#func open_scene(scene:PackedScene):
	#if current_scene :
		#current_scene.queue_free()
		#return
	#current_scene = scene
	#prune_objects()
	#var camp_scene = load("res://Scenes/Menus/CampMenu/camp_menu.tscn").instantiate()
	#self.add_child(camp_scene)
	#current_scene = camp_scene

func load_dialog_scene(file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	var text:String = file.get_as_text()
	var scene_data = JSON.parse_string(text)
	
	var dialog:DialogController = load("res://Scenes/Dialog/dialog_control.tscn").instantiate()
	dialog.scene_root = current_scene
	dialog.load_dialog_data(scene_data)
	if current_scene is CombatRootControl:
		current_scene.ui_control.add_child(dialog)
	else:
		current_scene.add_child(dialog)

func open_map_selection_menu():
	current_scene.queue_free()
	var new_scene = load("res://Scenes/Menus/MapSelectionMenu/map_selecction_menu.tscn").instantiate()
	self.add_child(new_scene)
	current_scene = new_scene
	
func open_shop_menu():
	LoadManager.load_scene("res://Scenes/Menus/ShopMenu/shop_menu.tscn")
	#current_scene.queue_free()
	#var new_scene = load("res://Scenes/Menus/ShopMenu/shop_menu.tscn").instantiate()
	#self.add_child(new_scene)
	#current_scene = new_scene

func open_character_sheet(_actor:BaseActor=null, parent_node=null)->CharacterMenuControl:
	var actor = _actor
	if not actor:
		actor = ActorLibrary.get_or_create_actor("TestActor", "TestActor_ID")
		#actor = ActorLibrary.create_actor("TestActor", {})
	var charsheet:CharacterMenuControl = load("res://Scenes/Menus/CharacterMenu/character_menu.tscn").instantiate()
	var screen_size = self.size
	var menu_scale = screen_size.y / charsheet.size.y
	#charsheet.scale_control.scale = Vector2(scale, scale)
	charsheet.scale_control.scale = Vector2(1, 1)
	#if screen_size.y > charsheet.size.y * 2:
	charsheet.scale_control.scale = Vector2(1.25,1.25)
	if parent_node:
		parent_node.add_child(charsheet)
	else:
		self.add_child(charsheet)
	#self.remove_child(center_container)
	#self.add_child(center_container)
	charsheet.set_actor(actor)
	return charsheet


func open_level_up_menu(actor:BaseActor):
	var level_up_menu:LevelUpContainer = load("res://Scenes/Menus/LevelUpMenu/level_up_container.tscn").instantiate()
	self.add_child(level_up_menu)
	level_up_menu.set_actor(actor)
	return level_up_menu
	

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

var dev_tools_menu
func open_dev_tools():
	if dev_tools_menu:
		return
	dev_tools_menu = load("res://Scenes/DevTools/dev_tools_menu.tscn").instantiate()
	if current_scene is CombatRootControl:
		CombatRootControl.Instance.camera.get_child(0).add_child(dev_tools_menu)
	else:
		self.add_child(dev_tools_menu)
	
func open_animation_tester():
	var node = load("res://Scenes/Editors/AnimationTester/animation_tester.tscn").instantiate()
	self.add_child(node)
	
	
func go_to_main_menu():
	if ActorLibrary.Instance:
		ActorLibrary.Instance.purge_actors()
	if ItemLibrary.Instance:
		ItemLibrary.Instance.purge_items()
	current_scene.queue_free()
	current_scene = load("res://Scenes/Menus/MainMenu/main_menu_root_control.tscn").instantiate()
	center_container.add_child(current_scene)
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_U:
			if dev_tools_menu:
				dev_tools_menu.close_menu()
				dev_tools_menu = null
			else:
				open_dev_tools()
func prune_objects():
	for actor_id in ActorLibrary.Instance._loaded_objects.keys():
		var actor:BaseActor = ActorLibrary.get_actor(actor_id)
		if not actor.is_player:
			ActorLibrary.delete_actor(actor)

#func next_quest():
	#if current_scene:
		#current_scene.queue_free()
	#StoryState.start_new_story("Soldier")
	#var combat_scene:CombatRootControl = load("res://Scenes/Combat/combat_scene.tscn").instantiate()
	#combat_scene.load_init_state("res://Scenes/Maps/StoryMaps/2_Cross_Road/crossroad_dialog_map.tscn")
	#current_scene = combat_scene
	#self.add_child(current_scene)
	#
	#var dialog:DialogController = load("res://Scenes/Dialog/dialog_control.tscn").instantiate()
	#dialog.scene_root = combat_scene
	#dialog.load_dialog_script("res://Scenes/Maps/StoryMaps/2_Cross_Road/crossroad_dialog_script.json")
	#combat_scene.camera.canvas_layer.add_child(dialog)
