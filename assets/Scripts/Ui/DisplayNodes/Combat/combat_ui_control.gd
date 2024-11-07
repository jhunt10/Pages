class_name CombatUiControl
extends Control

@export var menu_button:TextureButton 
@export var pause_menu:PauseMenuControl 

@export var stat_panel_control:StatPanelControl
@export var que_input:QueInputControl
@export var que_display:QueDisplayControl
@export var que_collection_display:QueCollectionControl
@export var stats_collection_display:StatCollectionDisplayControl

@onready var item_select_menu:ItemSelectMenuControl = $ItemSelectMenuControl

@onready var test_button:Button = $NextActorButton

static var Instance:CombatUiControl
static var ui_state_controller:UiStateController = UiStateController.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !Instance: Instance = self
	elif Instance != self:
		printerr(("Multiple UiStateController created."))
		self.queue_free()
		return
	menu_button.pressed.connect(_on_menu_pressed)
	test_button.pressed.connect(do_test)
	pass # Replace with function body.

func do_test():
	var current_actor_id = stat_panel_control.actor.Id
	var cur_index = CombatRootControl.Instance.GameState._actors.keys().find(current_actor_id)
	var next_index = (cur_index + 1) % CombatRootControl.Instance.GameState._actors.size()
	set_player_actor(CombatRootControl.Instance.GameState._actors.values()[next_index])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	ui_state_controller.update(delta)

func set_player_actor(actor:BaseActor):
	stat_panel_control.set_actor(actor)
	que_input.set_actor(actor)
	que_display.set_actor(actor)


func _input(event: InputEvent) -> void:
	# Escape Key Pressed
	if event is InputEventKey and (event as InputEventKey).keycode == KEY_ESCAPE and (event as InputEventKey).pressed:
		if not pause_menu.visible:
			if ui_state_controller.current_ui_state and ui_state_controller.current_ui_state.allow_pause_menu():
				pause_menu.visible = true
		else:
			pause_menu.visible = false

func _unhandled_input(event: InputEvent) -> void:
	ui_state_controller.handle_input(event)
		
func _on_menu_pressed():
	ui_state_controller.set_ui_state(UiStateController.UiStates.PauseMenu)
