class_name CombatLogController
extends BoxContainer

static var Instance:CombatLogController

@export var min_button:TextureButton
@export var max_button:TextureButton
@export var entries_container:BoxContainer
@export var scroll_container:ScrollContainer
@export var prefab_separator:HSeparator
@export var prefab_text_box:RichTextLabel

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
	prefab_text_box.hide()
	min_button.pressed.connect(_on_min)
	max_button.pressed.connect(_on_max)

func _on_min():
	min_button.hide()
	max_button.show()
	scroll_container.hide()

func _on_max():
	max_button.hide()
	min_button.show()
	scroll_container.show()

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
	elif event is String:
		var text_box = Instance.prefab_text_box.duplicate()
		text_box.text = event
		text_box.show()

func log_attack_event(event:AttackEvent):
	var new_entry:AttackLogEntry = load("res://Scenes/Combat/UiNodes/CombatLog/Entries/attack_log_entry.tscn").instantiate()
	new_entry.set_event(event)
	entries_container.add_child(new_entry)
	auto_scroll_delayed = true
	var sep = prefab_separator.duplicate()
	entries_container.add_child(sep)
	sep.show()
	
	
	
