class_name CharacterMenuConfirmationControl
extends Control

@export var yes_button:TextureButton
@export var no_button:TextureButton

var no_func = null
var yes_func = null

func _ready() -> void:
	yes_button.pressed.connect(_on_yes)
	no_button.pressed.connect(_on_no)

func show_pop_up(on_yes_func:Callable, on_no_func:Callable):
	no_func = on_no_func
	yes_func = on_yes_func
	self.show()

func _on_yes():
	if yes_func and yes_func is Callable:
		yes_func.call()
	no_func = null
	yes_func = null
	self.hide()

func _on_no():
	if no_func and no_func is Callable:
		no_func.call()
	no_func = null
	yes_func = null
	self.hide()
	
