class_name SaveSlotContainer
extends NinePatchRect

@export var selected:bool:
	set(val):
		selected = val
		if highlight:
			if mouse_over or selected:
				highlight.show()
			else:
				highlight.hide()
@export var mouse_over:bool:
	set(val):
		mouse_over = val
		print("Moues Over: %s " % [val])
		if highlight:
			if mouse_over or selected:
				highlight.show()
			else:
				highlight.hide()
@export var name_label:Label
@export var date_time_label:Label
@export var button:Button
@export var highlight:NinePatchRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	highlight.hide()
	button.mouse_entered.connect(on_mouse_enter)
	button.mouse_exited.connect(on_mouse_exit)

func on_mouse_enter():
	mouse_over = true
	mouse_entered.emit()
	
func on_mouse_exit():
	mouse_over = false
	mouse_exited.emit()
