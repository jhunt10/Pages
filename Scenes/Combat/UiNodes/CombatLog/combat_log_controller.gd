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
	CombatRootControl.Instance.QueController.start_of_round.connect(_on_round_start)
	CombatRootControl.Instance.QueController.start_of_turn.connect(_on_turn_start)

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
		Instance.entries_container.add_child(text_box)
		text_box.show()

func log_attack_event(event:AttackEvent):
	var new_entry:AttackLogEntry = load("res://Scenes/Combat/UiNodes/CombatLog/Entries/attack_log_entry.tscn").instantiate()
	new_entry.set_event(event)
	entries_container.add_child(new_entry)
	auto_scroll_delayed = true
	var sep = prefab_separator.duplicate()
	entries_container.add_child(sep)
	sep.show()
	
func _on_round_start():
	var sep = prefab_separator.duplicate()
	entries_container.add_child(sep)
	sep.show()
	var new_entry = prefab_text_box.duplicate()
	var round_index = CombatRootControl.Instance.QueController.round_counter
	new_entry.text = "Round " + str(int(round_index+1)) + ":"
	entries_container.add_child(new_entry)
	new_entry.show()
	var sep2 = prefab_separator.duplicate()
	entries_container.add_child(sep2)
	sep2.show()

func _on_turn_start():
	var sep = prefab_separator.duplicate()
	entries_container.add_child(sep)
	sep.show()
	var new_entry = prefab_text_box.duplicate()
	var turn_index = CombatRootControl.Instance.QueController.action_index
	new_entry.text = "Turn " + str(int(turn_index+1)) + ":"
	entries_container.add_child(new_entry)
	new_entry.show()
	var sep2 = prefab_separator.duplicate()
	entries_container.add_child(sep2)
	sep2.show()
