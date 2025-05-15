extends Node

signal progress_changed(progress)
signal load_done

var _load_screen_path:String = "res://assets/Scripts/Ui/Loading/loading_screen.tscn"
var _load_screen_script = load(_load_screen_path)
var _loaded_resource:PackedScene
var _scene_path:String
var _sub_scene_data:Dictionary
var _progress:Array = []
var _load_screen:LoadingScreen
var _combat_node:CombatRootControl

var _loading_done:bool
#var _last_scene_was_combat:bool

var use_sub_threads:bool = true

func load_combat(map_scene_path:String, dialog_script:String='', is_story_map=false):
	var data = {}
	data['MapPath'] = map_scene_path
	if dialog_script != '':
		data['DialogScript'] = dialog_script
	data['IsStoryMap'] = is_story_map
	load_scene("res://Scenes/Combat/combat_scene.tscn", data)

func load_scene(scene_path:String, sub_scene_data:Dictionary = {})->void:
	_sub_scene_data = sub_scene_data
	_scene_path = scene_path
	_load_screen = _load_screen_script.instantiate()
	var last_scene_was_combat = MainRootNode.Instance.current_scene is CombatRootControl
	
	if scene_path.ends_with("combat_scene.tscn"):
		_load_screen.load_scale = 50
		
	if last_scene_was_combat:
		MainRootNode.Instance.current_scene.camera.canvas_layer.add_child(_load_screen)
	else:
		get_tree().get_root().add_child(_load_screen)
	
	self.progress_changed.connect(_load_screen._update_progress)
	self.load_done.connect(_load_screen._start_outro_animation)

	await Signal(_load_screen, "loading_screen_has_full_coverage")
	
	# Fake duplicateing screen
	# Need old CombatScene gone before new one loads
	if last_scene_was_combat:
		MainRootNode.Instance.current_scene.camera.canvas_layer.remove_child(_load_screen)
		get_tree().get_root().add_child(_load_screen)
		MainRootNode.Instance.current_scene.queue_free()
		MainRootNode.Instance.current_scene.hide()
		
	start_load()

func start_load():
	_loading_done = false
	var state = ResourceLoader.load_threaded_request(_scene_path, "", use_sub_threads)
	if state == OK:
		set_process(true)

func _process(_delta: float) -> void:
	# Waiting for combat node to load actors
	if _waiting_for_combat:
		if _done_loading_combat:
			_load_screen.get_parent().remove_child(_load_screen)
			_combat_node.ui_control.add_child(_load_screen)
			MainRootNode.Instance.set_current_scene(_combat_node)
			var parent = _load_screen.get_parent()
			parent.remove_child(_load_screen)
			_combat_node.camera.canvas_layer.add_child(_load_screen)
			_combat_node = null
			_waiting_for_combat = false
			_done_loading_combat = false
			_conbat_load_thread.wait_to_finish()
			_conbat_load_thread = null
			finish_loading()
	else:
		var load_status = ResourceLoader.load_threaded_get_status(_scene_path, _progress)
		match load_status:
			0,2: #? Invalid Resource | Load Failed
				set_process(false)
				return
			1: # In progress
				emit_signal("progress_changed", _progress[0])
			3: # Done
				_loaded_resource = ResourceLoader.load_threaded_get(_scene_path)
				emit_signal("progress_changed", 1.0)
				handle_loaded_scene()

func handle_loaded_scene():
	printerr("handle_loaded_scene")
	var new_node = _loaded_resource.instantiate()
	if new_node is CombatRootControl:
		_waiting_for_combat = true
		_combat_node = new_node
		_conbat_load_thread = Thread.new()
		_conbat_load_thread.start(async_load_combat)
		return
		
	if new_node is CampMenu:
		if _sub_scene_data.has("DialogScript"):
			new_node.load_dialog(_sub_scene_data['DialogScript'])
	
	#if _last_scene_was_combat:
		#var parent = _load_screen.get_parent()
		#parent.remove_child(_load_screen)
		#get_tree().get_root().add_child(_load_screen)
		#_last_scene_was_combat = false
	
	_loading_done = true
	MainRootNode.Instance.set_current_scene(new_node)
	finish_loading()

func finish_loading():
	print("__FINISHED LOADING___")
	_loading_done = true
	emit_signal("load_done")
	set_process(false)

var _conbat_load_thread
var _waiting_for_combat:bool = false
var _done_loading_combat:bool = false
func async_load_combat():
	_combat_node.loading_actor_progressed.connect(_load_screen._combat_actor_loaded)
	_combat_node.load_init_state(_sub_scene_data)
	_done_loading_combat = true
