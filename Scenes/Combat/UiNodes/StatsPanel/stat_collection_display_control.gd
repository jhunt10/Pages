class_name StatCollectionDisplayControl
extends Control

@onready var premade_stat_panel: = $PremadePanelControl
@onready var panels_container = $PanelsContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	premade_stat_panel.visible = false
	_build_displays()
	CombatRootControl.Instance.actor_spawned.connect(on_new_actor)

func on_new_actor(actor:BaseActor):
	_build_displays()
	
func _build_displays():
	for child in panels_container.get_children():
		child.queue_free()
	for actor in CombatRootControl.Instance.GameState._actors.values():
		var new_display:StatPanelControl = premade_stat_panel.duplicate()
		new_display.visible = true
		new_display.set_actor(actor)
		panels_container.add_child(new_display)
