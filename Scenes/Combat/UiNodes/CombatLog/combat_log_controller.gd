#@tool
class_name CombatLogController
extends Control

static var Instance:CombatLogController

@export var entries_container:BoxContainer
@export var scroll_container:ScrollContainer
@export var back_patch:BackPatchContainer
@export var prefab_separator:HSeparator

var entries = []
var auto_scroll = false
var auto_scroll_delayed = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#super()
	if Engine.is_editor_hint():
		return
	if !Instance: Instance = self
	elif Instance != self: 
		printerr("Multiple CombatLogController found")
		queue_free()
		return
	prefab_separator.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#super(delta)
	if Engine.is_editor_hint():
		return
	
	if auto_scroll:
		scroll_container.set_deferred("scroll_vertical", scroll_container.get_v_scroll_bar().max_value+1000)
		auto_scroll = false
	
	if auto_scroll_delayed:
		auto_scroll_delayed = false
		auto_scroll = true
	pass

static func log_event(event):
	if Engine.is_editor_hint():
		return
	if !Instance:
		return
	Instance.entries.append(event)
	if event is AttackEvent:
		Instance.log_attack_event(event)

func log_attack_event(event:AttackEvent):
	var new_entry:AttackLogEntry = load("res://Scenes/Combat/UiNodes/CombatLog/Entries/attack_log_entry.tscn").instantiate()
	new_entry.set_event(event)
	entries_container.add_child(new_entry)
	auto_scroll_delayed = true
	var sep = prefab_separator.duplicate()
	entries_container.add_child(sep)
	sep.show()
	
	
	
