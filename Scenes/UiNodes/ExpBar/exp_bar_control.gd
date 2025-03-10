@tool
class_name ExpBarControl
extends TextureRect

@export var full_rect:Control
@export var color_rect:ColorRect
@export var level_label:Label

@export var mouse_over_control:Control
@export var current_exp_label:Label
@export var max_exp_label:Label
@export var percent_full:float:
	set(val):
		percent_full = max(min(val, 1), 0)
		if color_rect:
			color_rect.size.x = full_rect.size.x * percent_full

@export var level_up_button_control:Control
@export var level_up_button:Button

var _actor:BaseActor
var current_exp:float = 0
var max_exp:float = 1

func _ready() -> void:
	if mouse_over_control:
		mouse_over_control.hide()
		self.mouse_entered.connect(_on_mouse_enter)
		self.mouse_exited.connect(_on_mouse_exit)
	if level_up_button:
		level_up_button.pressed.connect(open_level_up_menu)

func set_actor(actor:BaseActor):
	if _actor:
		_actor.stats.stats_changed.disconnect(_sync)
	_actor = actor
	_actor.stats.stats_changed.connect(_sync)
	_sync()

func open_level_up_menu():
	MainRootNode.Instance.open_level_up_menu(_actor)

func _sync():
	if level_label:
		level_label.text = str(_actor.stats.get_stat(StatHelper.Level))
	current_exp = _actor.stats.get_stat(StatHelper.Experience)
	current_exp_label.text = str(current_exp)
	max_exp = _actor.stats.get_exp_to_next_level()
	max_exp_label.text = str(max_exp)
	self.percent_full = current_exp / max_exp
	if level_up_button_control:
		if current_exp >= max_exp:
			level_up_button_control.show()
		else:
			level_up_button_control.show()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_Y and _actor:
			_actor.stats.add_experiance(50)
			_sync()

func _on_mouse_enter():
	mouse_over_control.show()
func _on_mouse_exit():
	mouse_over_control.hide()
