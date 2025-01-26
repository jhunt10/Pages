extends Node

signal progress_changed(progress)
signal load_done

var _load_screen_path:String = "res://assets/Scripts/Ui/Loading/loading_screen.tscn"
var _load_screen_script = load(_load_screen_path)
var _loaded_resource:PackedScene
var _scene_path:String
var _sub_scene_path:String
var _progress:Array = []
var _load_screen:LoadingScreen
var _combat_node:CombatRootControl

var _conbat_load_thread
var _loading_done:bool

var use_sub_threads:bool = true

func load_combat(map_scene_path:String):
	_sub_scene_path = map_scene_path
	load_scene("res://Scenes/Combat/combat_scene.tscn")

func load_scene(scene_path:String)->void:
	_scene_path = scene_path
	_load_screen = _load_screen_script.instantiate()
	if scene_path.ends_with("combat_scene.tscn"):
		_load_screen.load_scale = 50
	get_tree().get_root().add_child(_load_screen)
	
	self.progress_changed.connect(_load_screen._update_progress)
	self.load_done.connect(_load_screen._start_outro_animation)

	await Signal(_load_screen, "loading_screen_has_full_coverage")
	
	start_load()

func start_load():
	_loading_done = false
	var state = ResourceLoader.load_threaded_request(_scene_path, "", use_sub_threads)
	if state == OK:
		set_process(true)

func _process(_delta: float) -> void:
	# Waiting for combat node to load actors
	if _combat_node:
		if _loading_done:
			_load_screen.get_parent().remove_child(_load_screen)
			_combat_node.ui_control.add_child(_load_screen)
			MainRootNode.Instance.set_current_scene(_combat_node)
			_combat_node = null
			emit_signal("load_done")
			set_process(false)
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
		_loading_done = false
		_combat_node = new_node
		_conbat_load_thread = Thread.new()
		_conbat_load_thread.start(async_load_combat)
	else:
		_loading_done = true
		MainRootNode.Instance.set_current_scene(new_node)
		emit_signal("load_done")
		set_process(false)
		#_conbat_load_thread.wait_to_finish()
	#set_process(false)
	#get_tree().scene(_loaded_resource)

func async_load_combat():
	_combat_node.loading_actor_progressed.connect(_load_screen._combad_actor_loaded)
	_combat_node.load_init_state(_sub_scene_path)
	_loading_done = true
	#_combat_node = null
	#_conbat_load_thread = null
