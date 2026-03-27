@tool
class_name MenuOptionLabel
extends Label

signal pressed

@export var disabled:bool:
	set(val):
		print("test")
		disabled = val
		if disabled:
			self.add_theme_color_override('font_color', disabled_color)
		else:
			self.add_theme_color_override('font_color', default_color)

@export var default_color:Color:
	set(val):
		default_color = val
		if not disabled:
			self.add_theme_color_override('font_color', default_color)

@export var pressed_color:Color
@export var disabled_color:Color
@export var under_line:ColorRect
@export var button:Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.mouse_entered.connect(_mouse_enter)
	button.mouse_exited.connect(_mouse_exit)
	button.button_down.connect(_button_down)
	button.button_up.connect(_button_up)
	under_line.hide()

func _mouse_enter():
	if disabled: return
	under_line.show()
func _mouse_exit():
	if disabled: return
	under_line.hide()
func _button_down():
	if disabled: return
	default_color = self.get_theme_color('font_color')
	self.add_theme_color_override('font_color', pressed_color)
func _button_up():
	if disabled: return
	self.add_theme_color_override('font_color', default_color)
	pressed.emit()
