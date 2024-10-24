class_name YesNoPopupContainer
extends CenterContainer

@export var message_label:Label
@export var yes_button:Button
@export var no_button:Button

var _message:String
var _on_yes:Callable
var _on_no:Callable

func _ready() -> void:
	yes_button.pressed.connect(on_yes_button_pressed)
	no_button.pressed.connect(on_no_button_pressed)
	message_label.text = _message

func set_message_and_funcs(message:String, on_yes_func, on_no_func):
	self._message = message
	if on_yes_func and on_yes_func is Callable:
		self._on_yes = on_yes_func
	if on_no_func and on_no_func is Callable:
		self._on_no = on_no_func

func on_yes_button_pressed():
	if _on_yes:
		_on_yes.call()
	self.queue_free()

func on_no_button_pressed():
	if _on_no:
		_on_no.call()
	self.queue_free()
